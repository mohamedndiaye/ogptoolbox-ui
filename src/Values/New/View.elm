module Values.New.View exposing (..)

import Cards.Autocomplete.View
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (..)
import Http.Error
import I18n
import Image.View exposing (..)
import Json.Decode
import Values.New.Types exposing (..)
import Views exposing (errorInfos)


fieldTypeLabelCouples : List ( String, I18n.TranslationId )
fieldTypeLabelCouples =
    [ ( "BooleanField", I18n.BooleanField )
    , ( "ImageField", I18n.ImageField )
    , ( "InputEmailField", I18n.InputEmailField )
    , ( "InputNumberField", I18n.InputNumberField )
    , ( "InputUrlField", I18n.InputUrlField )
    , ( "OrganizationIdField", I18n.OrganizationIdField )
    , ( "TextField", I18n.TextField )
    , ( "ToolIdField", I18n.ToolIdField )
    , ( "UseCaseIdField", I18n.UseCaseIdField )
    ]


view : Model -> Html Msg
view model =
    section []
        [ h1 [] [ text <| I18n.translate model.language I18n.NewValue ]
        , viewForm I18n.Create model
        ]


viewForm : I18n.TranslationId -> Model -> Html Msg
viewForm submitButtonI18n model =
    let
        language =
            model.language

        alert =
            case model.httpError of
                Nothing ->
                    []

                Just httpError ->
                    [ div
                        [ class "alert alert-danger"
                        , role "alert"
                        ]
                        [ strong []
                            [ text <|
                                I18n.translate language I18n.ValueCreationFailed
                                    ++ I18n.translate language I18n.Colon
                            ]
                        , text <| Http.Error.toString language httpError
                        ]
                    ]
    in
        Html.form
            [ onSubmit (ForSelf <| Submit) ]
            (alert
                ++ (viewFormControls model)
                ++ [ button
                        [ class "btn btn-primary"
                        , disabled (model.field == Nothing)
                        , type_ "submit"
                        ]
                        [ text (I18n.translate language submitButtonI18n) ]
                   ]
            )


viewFormControls : Model -> List (Html Msg)
viewFormControls model =
    let
        language =
            model.language
    in
        [ let
            validFieldTypeLabelCouples =
                if List.isEmpty model.validFieldTypes then
                    fieldTypeLabelCouples
                else
                    List.filter
                        (\( symbol, labelI18n ) -> List.member symbol model.validFieldTypes)
                        fieldTypeLabelCouples
          in
            if List.length validFieldTypeLabelCouples == 1 then
                text ""
            else
                let
                    controlId =
                        "fieldType"

                    ( errorClass, errorAttributes, errorBlock ) =
                        errorInfos language controlId (Dict.get controlId model.errors)
                in
                    div [ class ("form-group" ++ errorClass) ]
                        ([ label
                            [ class "control-label", for controlId ]
                            [ text <| I18n.translate language I18n.Type ]
                         , select
                            ([ class "form-control"
                             , id controlId
                             , on "change"
                                (Json.Decode.map (ForSelf << FieldTypeChanged)
                                    targetValue
                                )
                             ]
                                ++ errorAttributes
                            )
                            (validFieldTypeLabelCouples
                                |> List.map
                                    (\( symbol, labelI18n ) ->
                                        ( symbol
                                        , I18n.translate language labelI18n
                                        )
                                    )
                                |> List.sortBy (\( symbol, label ) -> label)
                                |> List.map
                                    (\( fieldType, label ) ->
                                        option
                                            [ selected (fieldType == model.fieldType)
                                            , value fieldType
                                            ]
                                            [ text label ]
                                    )
                            )
                         ]
                            ++ errorBlock
                        )
        , if model.fieldType == "TextField" then
            let
                controlId =
                    "language"

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label
                        [ class "control-label", for controlId ]
                        [ text <| I18n.translate language I18n.LanguageWord ]
                     , select
                        ([ class "form-control"
                         , id controlId
                         , on "change"
                            (Json.Decode.map (ForSelf << LanguageChanged)
                                targetValue
                            )
                         ]
                            ++ errorAttributes
                        )
                        (I18n.languages
                            |> List.map
                                (\languageI18n ->
                                    ( I18n.iso639_1FromLanguage languageI18n
                                    , I18n.translate language (I18n.Language languageI18n)
                                    )
                                )
                            |> List.sortBy (\( languageIso639_1, languageLabel ) -> languageLabel)
                            |> (::) ( "", I18n.translate language I18n.EveryLanguage )
                            |> List.map
                                (\( languageIso639_1, languageLabel ) ->
                                    option
                                        [ selected (languageIso639_1 == model.languageIso639_1)
                                        , value languageIso639_1
                                        ]
                                        [ text languageLabel ]
                                )
                        )
                     ]
                        ++ errorBlock
                    )
          else
            text ""
        , if model.fieldType == "BooleanField" then
            let
                controlId =
                    "value"

                controlTitle =
                    I18n.translate language I18n.EnterBoolean

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-check" ++ errorClass) ]
                    ([ label [ class "form-check-label", for controlId ]
                        [ input
                            ([ checked model.booleanValue
                             , class "form-check-input"
                             , id controlId
                             , title controlTitle
                             , type_ "checkbox"
                             , onCheck (ForSelf << ValueChecked)
                             ]
                                ++ errorAttributes
                            )
                            []
                        , text " "
                        , text <|
                            if model.booleanValue then
                                I18n.translate language I18n.TrueWord
                            else
                                I18n.translate language I18n.FalseWord
                        ]
                     ]
                        ++ errorBlock
                    )
          else if model.fieldType == "InputEmailField" then
            let
                controlId =
                    "value"

                controlLabel =
                    I18n.translate language I18n.Email

                controlPlaceholder =
                    I18n.translate language I18n.EmailPlaceholder

                controlTitle =
                    I18n.translate language I18n.EnterEmail

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label [ class "control-label", for controlId ] [ text controlLabel ]
                     , input
                        ([ class "form-control"
                         , id controlId
                         , placeholder controlPlaceholder
                         , title controlTitle
                         , type_ "email"
                         , value model.value
                         , onInput (ForSelf << ValueChanged)
                         ]
                            ++ errorAttributes
                        )
                        []
                     ]
                        ++ errorBlock
                    )
          else if model.fieldType == "InputNumberField" then
            let
                controlId =
                    "value"

                controlLabel =
                    I18n.translate language I18n.Number

                controlPlaceholder =
                    I18n.translate language I18n.NumberPlaceholder

                controlTitle =
                    I18n.translate language I18n.EnterNumber

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label [ class "control-label", for controlId ] [ text controlLabel ]
                     , input
                        ([ class "form-control"
                         , id controlId
                         , placeholder controlPlaceholder
                         , title controlTitle
                         , type_ "number"
                         , value model.value
                         , onInput (ForSelf << ValueChanged)
                         ]
                            ++ errorAttributes
                        )
                        []
                     ]
                        ++ errorBlock
                    )
          else if model.fieldType == "InputUrlField" then
            let
                controlId =
                    "value"

                controlLabel =
                    I18n.translate language I18n.Url

                controlPlaceholder =
                    I18n.translate language I18n.UrlPlaceholder

                controlTitle =
                    I18n.translate language I18n.EnterUrl

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label [ class "control-label", for controlId ] [ text controlLabel ]
                     , input
                        ([ class "form-control"
                         , id controlId
                         , placeholder controlPlaceholder
                         , title controlTitle
                         , type_ "url"
                         , value model.value
                         , onInput (ForSelf << ValueChanged)
                         ]
                            ++ errorAttributes
                        )
                        []
                     ]
                        ++ errorBlock
                    )
          else if model.fieldType == "TextField" then
            let
                controlId =
                    "value"

                controlLabel =
                    I18n.translate language I18n.Value

                controlPlaceholder =
                    I18n.translate language I18n.ValuePlaceholder

                controlTitle =
                    I18n.translate language I18n.EnterValue

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label [ class "control-label", for controlId ] [ text controlLabel ]
                     , textarea
                        ([ class "form-control"
                         , id controlId
                         , placeholder controlPlaceholder
                         , title controlTitle
                         , onInput (ForSelf << ValueChanged)
                         , value model.value
                         ]
                            ++ errorAttributes
                        )
                        []
                     ]
                        ++ errorBlock
                    )
          else
            text ""
        , if model.fieldType == "ImageField" then
            let
                controlId =
                    -- Note: ID is given by State to Ports.fileSelected.
                    "new-image"

                controlLabel =
                    I18n.translate language I18n.Image

                controlTitle =
                    I18n.translate language I18n.EnterImage

                ( errorClass, errorAttributes, errorBlock ) =
                    errorInfos language controlId (Dict.get controlId model.errors)
            in
                div [ class ("form-group" ++ errorClass) ]
                    ([ label [ class "control-label", for controlId ] [ text controlLabel ]
                     , input
                        ([ class "form-control-file"
                         , id controlId
                         , title controlTitle
                         , type_ "file"
                         , on "change" (Json.Decode.succeed (ForSelf ImageSelected))
                         ]
                            ++ errorAttributes
                        )
                        []
                     ]
                        ++ errorBlock
                        ++ [ viewImageUploadStatus language model.imageUploadStatus ]
                    )
          else if model.fieldType == "OrganizationIdField" then
            let
                controlId =
                    "cardId"
            in
                Cards.Autocomplete.View.viewAutocomplete
                    language
                    controlId
                    (I18n.Organization I18n.Singular)
                    I18n.OrganizationPlaceholder
                    (Dict.get controlId model.errors)
                    model.cardsAutocompleteModel
                    |> Html.map translateCardsAutocompleteMsg
          else if model.fieldType == "ToolIdField" then
            let
                controlId =
                    "cardId"
            in
                Cards.Autocomplete.View.viewAutocomplete
                    language
                    controlId
                    (I18n.Tool I18n.Singular)
                    I18n.ToolPlaceholder
                    (Dict.get controlId model.errors)
                    model.cardsAutocompleteModel
                    |> Html.map translateCardsAutocompleteMsg
          else if model.fieldType == "UseCaseIdField" then
            let
                controlId =
                    "cardId"
            in
                Cards.Autocomplete.View.viewAutocomplete
                    language
                    controlId
                    (I18n.UseCase I18n.Singular)
                    I18n.UseCasePlaceholder
                    (Dict.get controlId model.errors)
                    model.cardsAutocompleteModel
                    |> Html.map translateCardsAutocompleteMsg
          else
            text ""
        ]
