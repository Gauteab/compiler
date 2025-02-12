{-# LANGUAGE OverloadedStrings #-}

module Parse.MultilineStringSpec where

import AST.Source qualified as Src
import Data.ByteString qualified as BS
import Data.Utf8 qualified as Utf8
import Helpers.Instances ()
import Helpers.Parse qualified as Helpers
import Parse.Pattern qualified as Pattern
import Reporting.Error.Syntax qualified as Error.Syntax
import Test.Hspec (Spec, describe, it)

spec :: Spec
spec = do
  describe "Multiline String" $ do
    it "regression test" $
      parse
        "normal string"
        "\"\"\"normal string\"\"\""

    it "mixing quotes work" $ do
      parse
        "string with \" in it"
        "\"\"\"string with \" in it\"\"\""

    it "first newline, and leading whitespace, is dropped" $ do
      parse
        "this is\\na test"
        "\"\"\"\n   this is\n   a test\n\"\"\""

    it "First proper line decides how many spaces to drop" $ do
      parse
        "this is\\n a test"
        "\"\"\"\n   this is\n    a test\n\"\"\""

    it "Only leading spaces are dropped" $ do
      parse
        "this is\\na test"
        "\"\"\"\n   this is\n a test\n\"\"\""

parse :: String -> BS.ByteString -> IO ()
parse expectedStr =
  let isExpectedString :: Src.Pattern_ -> Bool
      isExpectedString pattern =
        case pattern of
          Src.PStr str ->
            expectedStr == Utf8.toChars str
          _ ->
            False
   in Helpers.checkSuccessfulParse (fmap (\((pat, _), loc) -> (pat, loc)) Pattern.expression) Error.Syntax.PStart isExpectedString
