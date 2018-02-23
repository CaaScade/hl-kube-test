{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Options where

import           Import

import           Options.Applicative

data Options = Options
  { root       :: Text
  , kubeconfig :: Text
  , namespace  :: Text
  , channel    :: Text
  }

data Command = CleanCommand Options | StartCommand Options

parseOptions :: Text -> Text -> Parser Options
parseOptions defaultRoot defaultKubeconfig =
  Options <$> parseRoot <*> parseKubeconfig <*> parseNamespace <*> parseChannel
  where
    parseRoot =
      option
        str
        (long "root" <>
         help "root directory containing bin/, config/, short-config/" <>
         metavar "ROOT_DIRECTORY" <>
         showDefault <>
         value defaultRoot)
    parseKubeconfig =
      option
        str
        (long "kubeconfig" <> help "kubernetes config file" <>
         metavar "KUBE_CONFIG" <>
         showDefault <>
         value defaultKubeconfig)
    parseNamespace =
      option
        str
        (long "namespace" <> help "kubernetes namespace to use" <>
         metavar "KUBE_NAMESPACE" <>
         showDefault <>
         value "fabric-dev")
    parseChannel =
      option
        str
        (long "channel" <> help "name of channel to generate sample artifacts for" <>
         metavar "CHANNEL_ID" <>
         showDefault <>
         value "samplechannel")

parseCommand :: Text -> Text -> Parser Command
parseCommand defaultRoot defaultKubeconfig =
  hsubparser (command "clean" cleanInfo <> command "start" startInfo)
  where
    cleanInfo =
      info
        (CleanCommand <$> optParser)
        (progDesc "clean up the development installation of Fabric")
    startInfo =
      info
        (StartCommand <$> optParser)
        (progDesc "start a development installation of Fabric")
    optParser = parseOptions defaultRoot defaultKubeconfig
