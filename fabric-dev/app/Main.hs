{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE OverloadedStrings    #-}

module Main where

import           Import

import qualified Data.Text as T
import           Shelly
import qualified Shelly as SH

main :: IO ()
main = shelly . verbosely $ do
  buildConfig root channelID
  bundleConfig root
  deployWorkload root
  where root = "/home/kynan/workspace/go/src/github.com/koki/fabric-dev/fabric-dev/testroot"
        channelID = "blubc"

deployWorkload :: SH.FilePath -> Sh ()
deployWorkload root = do
  cd root
  catchany_sh (rm_rf "./kube-config") (const $ return ())
  mkdir_p "./kube-config"
  sequence_ $ deleteKube "deployment" <$> peerKubeNames
  sequence_ $ deleteKube "service" <$> peerKubeNames
  deleteKube "deployment" "admin-peer0-org1-cli"
  deleteKube "deployment" "orderer-example-com"
  deleteKube "service" "orderer"
  deployShort "./short-config/orderer.short.yaml" "./kube-config/orderer.kube.yaml"
  deployShort "./short-config/peers.short.yaml" "./kube-config/peers.kube.yaml"
  deployShort "./short-config/clis.short.yaml" "./kube-config/clis.kube.yaml"
  where
    deleteKube resource name =
      catchany_sh
        (run_ "kubectl" ["delete", resource, name])
        (const $ return ())
    createKube file =
      run_ "kubectl" ["create", "-f", file]
    unshort file output = do
      kubed <- run "short" ["-k", "-f", file]
      writefile output kubed
    deployShort file output = do
      unshort file output
      createKube =<< toTextWarn output
    peerKubeName peer org = peer <> "-" <> org
    peerKubeNames = peerKubeName <$> ["peer0", "peer1"] <*> ["org1", "org2"]

buildConfig :: SH.FilePath -> Text -> Sh ()
buildConfig root channelID = do
  prependToPath $ root <> "bin"
  cd root
  catchany_sh (rm_rf "./crypto-config") (const $ return ())
  catchany_sh (rm_rf "./channel-artifacts") (const $ return ())
  -- Write crypto-config into the config directory because configtxgen can only look there.
  run_ "cryptogen" ["generate", "--config=./config/crypto-config.yaml", "--output=./config/crypto-config"]
  mkdir_p "./channel-artifacts"
  currentDir <- pwd
  setenv "FABRIC_CFG_PATH" =<< toTextWarn (currentDir <> "config")
  run_ "configtxgen" ["-profile", "TwoOrgsOrdererGenesis", "-outputBlock", "./channel-artifacts/genesis.block"]
  run_ "configtxgen" ["-profile", "TwoOrgsChannel", "-outputCreateChannelTx", "./channel-artifacts/channel.tx", "-channelID", channelID]
  run_ "configtxgen" ["-profile", "TwoOrgsChannel", "-outputAnchorPeersUpdate", "./channel-artifacts/Org1MSPanchors.tx", "-channelID", channelID, "-asOrg", "Org1MSP"]
  run_ "configtxgen" ["-profile", "TwoOrgsChannel", "-outputAnchorPeersUpdate", "./channel-artifacts/Org2MSPanchors.tx", "-channelID", channelID, "-asOrg", "Org2MSP"]
  -- Put the crypto-config where it belongs.
  mv "config/crypto-config" root

-- NOTE: *SecretName functions need to ensure lowercase & no periods
-- TODO: k8s namespace
bundleConfig :: SH.FilePath -> Sh ()
bundleConfig root = do
  let peerOrgs = ["org1", "org2"]
      peerPeers = ["peer0", "peer1"]
      peerUsers = ["Admin", "User1"]
      folders = ["msp", "tls"]
  cd root
  mkdir_p "config-artifacts"
  sequence_ $ bundlePeer <$> peerPeers <*> peerOrgs <*> folders
  sequence_ $ bundleOrderer <$> folders
  sequence_ $ bundleUser "peer" <$> peerUsers <*> peerOrgs <*> folders
  sequence_ $ bundleUser "orderer" "Admin" "example.com" <$> folders
  deploySecret "orderer-genesis-block" "channel-artifacts/genesis.block" "file"
  deployConfigMap "core-yaml" "config/core.yaml" "file"
  deployConfigMap "orderer-yaml" "config/orderer.yaml" "file"
  where
    bundlePeer peer org folder =
      let input = peerFolderName peer org
          output = inOutputFolder $ peerBundleName peer org folder
          deploy = peerSecretName peer org folder
      in do run_ "tar" ["-zcf", output, "-C", input, folder]
            deploySecret deploy output "bundle"
    peerBundleName peer org folder =
      T.intercalate "." [peer, org, folder, "tar.gz"]
    peerFolderName peer org =
      T.intercalate
        "/"
        ["crypto-config/peerOrganizations", org, "peers", peer <> "." <> org]
    peerSecretName peer org folder = T.intercalate "-" [peer, org, folder]
    bundleOrderer folder =
      let input = ordererFolderName
          output = inOutputFolder $ ordererBundleName folder
          deploy = ordererSecretName folder
      in do run_ "tar" ["-zcf", output, "-C", input, folder]
            deploySecret deploy output "bundle"
    ordererBundleName folder =
      T.intercalate "." ["orderer.example.com", folder, "tar.gz"]
    ordererFolderName =
      "crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com"
    ordererSecretName folder = "orderer-example-com-" <> folder
    bundleUser t user org folder =
      let input = userFolderName t user org
          output = inOutputFolder $ userBundleName user org folder
          deploy = userSecretName user org folder
      in do
        run_ "tar" ["-zcf", output, "-C", input, folder]
        deploySecret deploy output "bundle"
    userBundleName user org folder =
      T.intercalate "." [user <> "@" <> org, folder, "tar.gz"]
    userFolderName t user org =
      T.intercalate
        "/"
        [ "crypto-config"
        , t <> "Organizations"
        , org
        , "users"
        , user <> "@" <> org
        ]
    userSecretName user org folder =
      T.intercalate "-" [T.toLower user, org, folder]
    deploySecret name file key = do
      let delete = run_ "kubectl" ["delete", "secret", name]
          options = T.intercalate "=" ["--from-file", key, file]
      catchany_sh delete (const $ return ())
      run_ "kubectl" ["create", "secret", "generic", name, options]
    deployConfigMap name file key = do
      let delete = run_ "kubectl" ["delete", "configmap", name]
          options = T.intercalate "=" ["--from-file", key, file]
      catchany_sh delete (const $ return ())
      run_ "kubectl" ["create", "configmap", name, options]
    inOutputFolder file = "config-artifacts" <> "/" <> file
