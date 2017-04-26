module Collections.Edit.View exposing (..)

import Cards.Autocomplete.View
import Collections.Edit.Types exposing (..)
import Collections.ViewsHelpers exposing (..)
import Dict exposing (Dict)
import Json.Decode as Decode
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (..)
import Http.Error
import Image.View exposing (..)
import I18n
import Views exposing (..)


view : Model -> Html Msg
view model =
    let
        language =
            model.language

        alert =
            case model.httpError of
                Just httpError ->
                    [ div
                        [ class "alert alert-danger"
                        , role "alert"
                        ]
                        [ strong []
                            [ text <|
                                I18n.translate language I18n.CollectionSubmissionFailed
                                    ++ I18n.translate language I18n.Colon
                            ]
                        , text <| Http.Error.toString language httpError
                        ]
                    ]

                Nothing ->
                    []
    in
        Html.form
            [ onSubmit (ForSelf PostCollection) ]
            (alert
                ++ [ div [ class "row section" ]
                        [ div [ class "container" ]
                            [ div [ class "row" ]
                                [ div [ class "col-md-12 content content-left" ]
                                    [ div [ class "row" ]
                                        [ div [ class "col-xs-12" ]
                                            [ h1 []
                                                [ text
                                                    (case model.editedCollectionId of
                                                        Nothing ->
                                                            (I18n.translate language I18n.AddCollection)

                                                        Just _ ->
                                                            (I18n.translate language I18n.EditCollection)
                                                    )
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            , div [ class "row" ]
                                [ div [ class "col-md-9 content content-left" ]
                                    [ div [ class "row" ]
                                        [ div [ class "col-xs-12" ]
                                            [ div [ class "row section-form" ]
                                                [ div [ class "col-xs-12" ]
                                                    [ viewNameControl
                                                        (ForSelf << SetName)
                                                        language
                                                        I18n.CollectionNamePlaceholder
                                                        model.errors
                                                        model.name
                                                    , viewDescriptionControl
                                                        (ForSelf << SetDescription)
                                                        language
                                                        I18n.CollectionDescriptionPlaceholder
                                                        model.errors
                                                        model.description
                                                    , viewToolsThumbnailsPanel
                                                        language
                                                        (ForParent << Navigate)
                                                        (Just (ForSelf << RemoveCard))
                                                        model.data
                                                        model.cardIds
                                                    , let
                                                        controlId =
                                                            "toolsAutocomplete"
                                                      in
                                                        Cards.Autocomplete.View.viewAutocomplete
                                                            language
                                                            controlId
                                                            I18n.AddTool
                                                            I18n.ToolPlaceholder
                                                            (Dict.get controlId model.errors)
                                                            model.toolsAutocompleteModel
                                                            |> Html.map translateToolsAutocompleteMsg
                                                    , viewUseCasesThumbnailsPanel
                                                        language
                                                        (ForParent << Navigate)
                                                        (Just (ForSelf << RemoveCard))
                                                        model.data
                                                        model.cardIds
                                                    , let
                                                        controlId =
                                                            "useCasesAutocomplete"
                                                      in
                                                        Cards.Autocomplete.View.viewAutocomplete
                                                            language
                                                            controlId
                                                            I18n.AddUseCase
                                                            I18n.UseCasePlaceholder
                                                            (Dict.get controlId model.errors)
                                                            model.useCasesAutocompleteModel
                                                            |> Html.map translateUseCasesAutocompleteMsg
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                , div [ class "col-md-3 sidebar" ]
                                    [ div [ class "row" ]
                                        [ div [ class "col-xs-12" ]
                                            [ div [ class "thumbnail orga grey" ]
                                                [ div [ class "upload-container" ]
                                                    [ label [ for "logoField" ]
                                                        [ text (I18n.translate language (I18n.Logo)) ]
                                                    , div [ class "upload-zone" ]
                                                        [ viewImageUploadStatus language model.imageUploadStatus ]
                                                    , input
                                                        [ id "logoField"
                                                        , on "change" (Decode.succeed (ForSelf ImageSelected))
                                                        , type_ "file"
                                                        ]
                                                        []
                                                    ]
                                                ]
                                            ]
                                        ]

                                    -- , div [ class "row" ]
                                    --     [ div [ class "col-xs-12" ]
                                    --         [ i []
                                    --             [ text "Maecenas " ]
                                    --         ]
                                    --     ]
                                    ]
                                ]
                            ]
                        ]
                   , div [ class "row section-form last" ]
                        [ div [ class "container" ]
                            [ div [ class "col-md-9 content content-left" ]
                                [ button
                                    [ class "btn btn-default pull-right"
                                    , disabled (model.collectionJson == Nothing)
                                    , type_ "submit"
                                    ]
                                    [ text (I18n.translate language (I18n.PublishCollection))

                                    -- TODO i18n
                                    ]
                                ]
                            ]
                        ]
                   ]
            )
