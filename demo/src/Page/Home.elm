module Page.Home exposing (..)

import Array
import BasicEditor
import Html exposing (Html, h1, text)
import Html.Attributes exposing (class)
import RichTextEditor.MarkdownSpec exposing (code, doc, image, paragraph)
import RichTextEditor.Model.Annotation exposing (selectableAnnotation)
import RichTextEditor.Model.Attribute exposing (Attribute(..))
import RichTextEditor.Model.Mark exposing (mark)
import RichTextEditor.Model.Node
    exposing
        ( BlockNode
        , InlineLeaf(..)
        , blockArray
        , blockNode
        , elementParameters
        , emptyTextLeafParameters
        , inlineLeafArray
        , inlineLeafParameters
        , textLeafParametersWithMarks
        , textLeafWithText
        , withText
        )
import RichTextEditor.Model.State as State exposing (State)
import Session exposing (Session)
import Set


type alias Model =
    { session : Session
    , editor : BasicEditor.Model
    }


type Msg
    = Msg
    | EditorMsg BasicEditor.EditorMsg
    | GotSession Session


dummyView : { title : String, content : List (Html msg) }
dummyView =
    { title = "Dummy Home", content = [ text "Dummy Home" ] }


view : Model -> { title : String, content : List (Html Msg) }
view model =
    { title = "Home"
    , content =
        [ h1 [ class "main-header" ]
            [ text "Elm package for building rich text editors" ]
        , Html.map EditorMsg (BasicEditor.view model.editor)
        ]
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, editor = BasicEditor.init initialState }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg editorMsg ->
            let
                ( e, _ ) =
                    BasicEditor.update editorMsg model.editor
            in
            -- TODO: hook up commands from full editor
            ( { model | editor = e }, Cmd.none )

        _ ->
            ( model, Cmd.none )


toSession : Model -> Session
toSession model =
    model.session


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



----


initNode : BlockNode
initNode =
    blockNode
        (elementParameters doc [] Set.empty)
        (blockArray (Array.fromList [ initialEditorNode ]))


initialEditorNode : BlockNode
initialEditorNode =
    blockNode
        (elementParameters paragraph [] Set.empty)
        (inlineLeafArray
            (Array.fromList
                [ textLeafWithText <|
                    "Rich Text Editor Toolkit is an open source project to make cross platform editors on the web. "
                        ++ "This package treats "
                , TextLeaf
                    (emptyTextLeafParameters
                        |> withText "contenteditable"
                        |> textLeafParametersWithMarks [ mark code [] ]
                    )
                , textLeafWithText <|
                    " as an I/O device, and uses browser events and mutation observers "
                        ++ "to detect changes and update itself.  The editor's model itself is defined "
                        ++ "and validated by a programmable specification that allows you to create a "
                        ++ "custom tailored editor that fits your needs."
                ]
            )
        )


initialState : State
initialState =
    State.state initNode Nothing