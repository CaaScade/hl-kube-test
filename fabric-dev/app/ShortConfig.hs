{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module ShortConfig where

import           Import

import qualified Data.Aeson as AE
import qualified Data.Text  as T
import qualified Data.Yaml  as Y

data ConfigWrapper a = ConfigWrapper
  { configConfig :: a
  } deriving (Generic, Show)

configOptions = AE.defaultOptions {AE.fieldLabelModifier = toLower . drop 6}

instance AE.ToJSON a => AE.ToJSON (ConfigWrapper a) where
  toJSON = AE.genericToJSON configOptions
  toEncoding = AE.genericToEncoding configOptions

{-
config:
  namespace: fabric-dev
  name: peer0
  org: org1
  service_name: peer0-org1
-}

mkPeerServiceName peer org = peer <> "-" <> org

mkPeerConfig namespace peer org =
  PeerConfig
  { peerName = peer
  , peerOrg = org
  , peerService_Name = mkPeerServiceName peer org
  , peerNamespace = namespace
  }

data PeerConfig = PeerConfig
  { peerNamespace    :: Text
  , peerName         :: Text
  , peerOrg          :: Text
  , peerService_Name :: Text
  } deriving (Generic, Show)

peerOptions = AE.defaultOptions {AE.fieldLabelModifier = toLower . drop 4}

instance AE.ToJSON PeerConfig where
  toJSON = AE.genericToJSON peerOptions
  toEncoding = AE.genericToEncoding peerOptions

{-
config:
  namespace: fabric-dev
-}

mkOrdererConfig = OrdererConfig

data OrdererConfig = OrdererConfig
  { ordererNamespace :: Text
  } deriving (Generic, Show)

ordererOptions = AE.defaultOptions {AE.fieldLabelModifier = toLower . drop 7}

instance AE.ToJSON OrdererConfig where
  toJSON = AE.genericToJSON ordererOptions
  toEncoding = AE.genericToEncoding ordererOptions

{-
config:
  namespace: fabric-dev
  user: Admin
  peer: peer0
  org: org1
  peer_service_name: peer0-org1
  admin_service_name: admin-org1
  client_service_name: admin-peer0-org1-cli
-}

mkCLIConfig namespace user peer org =
  CLIConfig
  { cliNamespace = namespace
  , cliUser = user
  , cliPeer = peer
  , cliOrg = org
  , cliPeer_Service_Name = peerName
  , cliAdmin_Service_Name = user' <> "-" <> org
  , cliClient_Service_Name = T.intercalate "-" [user', peer, org, "cli"]
  }
  where
    peerName = mkPeerServiceName peer org
    user' = toLower user

data CLIConfig = CLIConfig
  { cliNamespace           :: Text
  , cliUser                :: Text
  , cliPeer                :: Text
  , cliOrg                 :: Text
  , cliPeer_Service_Name   :: Text
  , cliAdmin_Service_Name  :: Text
  , cliClient_Service_Name :: Text
  } deriving (Generic, Show)

cliOptions = AE.defaultOptions {AE.fieldLabelModifier = toLower . drop 3}

instance AE.ToJSON CLIConfig where
  toJSON = AE.genericToJSON cliOptions
  toEncoding = AE.genericToEncoding cliOptions
