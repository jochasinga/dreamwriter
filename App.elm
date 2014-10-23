module App where

import Dreamwriter (Identifier)
import Dreamwriter.Action (..)
import Dreamwriter.Model (..)
import Dreamwriter.View.Page (view)

import String
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref
import Maybe
import Window

-- ACTIONS --

step : Action -> AppState -> AppState
step action state =
  case action of
    NoOp -> state

    OpenDocId id ->
      {state | currentDocId    <- Just id
             , leftSidebarView <- CurrentDocView
      }

    LoadAsCurrentDoc doc ->
      let stateAfterOpenDocId = step (OpenDocId doc.id) state
      in
        {stateAfterOpenDocId | currentDoc <- Just doc}

    ListDocs docs ->
      {state | docs <- docs}

    ListNotes notes ->
      {state | notes <- notes}

    SetCurrentNote currentNote ->
      {state | currentNote <- currentNote}

    SetChapters chapters ->
      case state.currentDoc of
        Nothing -> state
        Just doc ->
          let newCurrentDoc = {doc | chapters <- chapters}
          in
            {state | currentDoc <- Just newCurrentDoc}

    SetLeftSidebarView mode ->
      {state | leftSidebarView <- mode}

main : Signal Element
main = lift2 scene state Window.dimensions

userInput : Signal Action
userInput =
  merges
  [ lift LoadAsCurrentDoc loadAsCurrentDoc
  , lift ListDocs         listDocs
  , lift ListNotes        listNotes
  , lift SetChapters      setChapters
  , actions.signal
  ]

scene : AppState -> (Int, Int) -> Element
scene state (w, h) =
  container w h midTop (toElement w h (view state))

-- manage the state of our application over time
state : Signal AppState
state = foldp step emptyState userInput

port loadAsCurrentDoc : Signal Doc
port setChapters : Signal [Chapter]
port listDocs : Signal [Doc]
port listNotes : Signal [Note]

port setCurrentDocId : Signal (Maybe Identifier)
port setCurrentDocId = lift .currentDocId state

port newDoc : Signal ()
port newDoc = newDocInput.signal

port openFromFile : Signal ()
port openFromFile = openFromFileInput.signal

port downloadDoc : Signal DownloadOptions
port downloadDoc = downloadInput.signal

port printDoc : Signal ()
port printDoc = printInput.signal

port navigateToChapterId : Signal Identifier
port navigateToChapterId = navigateToChapterIdInput.signal

port navigateToTitle : Signal ()
port navigateToTitle = navigateToTitleInput.signal

port newNote : Signal ()
port newNote = newNoteInput.signal

port searchNotes : Signal ()
port searchNotes = searchNotesInput.signal

port fullscreen : Signal Bool
port fullscreen = fullscreenInput.signal