{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Site.Forum.Controller.Form.Comment
( formCreate
) where

------------------------------------------------------------------------------
import           Common
------------------------------------------------------------------------------
import           Control.Monad.Trans (MonadIO(..))
------------------------------------------------------------------------------
import qualified Text.Reform.Extra      as HA
import           Text.Reform                  ((<++), (++>))
import qualified Text.Reform.Blaze.Text as HA
import qualified Text.Blaze.Html as B (Html)
------------------------------------------------------------------------------
import qualified Data.Text      as TS 
import qualified Data.Text.Lazy as TL
------------------------------------------------------------------------------
import           Site.Common.Model
import           Site.Common.Controller.Form
------------------------------------------------------------------------------
import qualified Site.Core.Model.Type  as IC
import qualified Site.Forum.Model.Type as IF
------------------------------------------------------------------------------

formCreate :: (Functor m, MonadIO m, IF.HasForum m)
           => Maybe IC.IdentityID
           -> IF.PostID
           -> Maybe IF.CommentID
           -> Form m B.Html () IF.CommentData
formCreate miid pid mparent = construct
    <$> HA.label ("Content: " :: String)
        ++> commentContent
        <++ HA.br
    <*> HA.label ("Anonymous: " :: String)
        ++> HA.inputCheckbox False
        <++ HA.br
    <* HA.inputSubmit "Save"
    where
      construct c a = IF.CommentData
        { IF.commentAuthor = if a then Nothing else miid
        , IF.commentContent = c
        , IF.commentParent = mparent
        , IF.commentPost = pid
        }

commentContent :: (Functor m, Monad m)
               => Form m B.Html () Content 
commentContent = content . TL.fromChunks . (:[]) <$> 
    HA.checkBool (\x -> let l = TS.length x in l >= 10 && l <= 15000) (FERequiredLength 10 15000) (
    HA.textarea 80 10 "" 
    )

