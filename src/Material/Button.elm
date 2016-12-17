module Material.Button
    exposing
        ( Model
        , defaultModel
        , Msg
        , update
        , view
        , flat
        , raised
        , fab
        , minifab
        , icon
        , plain
        , colored
        , primary
        , accent
        , ripple
        , disabled
        , Property
        , render
        , type'
        )

{-| From the [Material Design Lite documentation](http://www.getmdl.io/components/#buttons-section):

> The Material Design Lite (MDL) button component is an enhanced version of the
> standard HTML `<button>` element. A button consists of text and/or an image that
> clearly communicates what action will occur when the user clicks or touches it.
> The MDL button component provides various types of buttons, and allows you to
> add both display and click effects.
>
> Buttons are a ubiquitous feature of most user interfaces, regardless of a
> site's content or function. Their design and use is therefore an important
> factor in the overall user experience. See the button component's Material
> Design specifications page for details.
>
> The available button display types are flat (default), raised, fab, mini-fab,
> and icon; any of these types may be plain (light gray) or colored, and may be
> initially or programmatically disabled. The fab, mini-fab, and icon button
> types typically use a small image as their caption rather than text.

See also the
[Material Design Specification]([https://www.google.com/design/spec/components/buttons.html).

Refer to
[this site](https://debois.github.io/elm-mdl/#buttons)
for a live demo.

# Render
@docs render

# Options

@docs Property
@docs type'

## Appearance
@docs plain, colored, primary, accent
@docs ripple, disabled

## Type
Refer to the
[Material Design Specification](https://www.google.com/design/spec/components/buttons.html)
for details about what type of buttons are appropriate for which situations.
@docs flat, raised, fab, minifab, icon

# Elm architecture
@docs Model, defaultModel, Msg, update, view


-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Platform.Cmd exposing (Cmd, none)
import Parts exposing (Indexed, Index)
import Material.Helpers as Helpers
import Material.Options.Internal as Internal
import Material.Options as Options exposing (cs, when)
import Material.Options.Internal as Internal
import Material.Ripple as Ripple
import Material.Msg as Material


-- MODEL


{-|
-}
type alias Model =
    Ripple.Model


{-|
-}
defaultModel : Model
defaultModel =
    Ripple.model



-- ACTION, UPDATE


{-|
-}
type alias Msg =
    Ripple.Msg


{-| Component update.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action =
    Ripple.update action



-- VIEW


type alias Config =
    { ripple : Bool
    }


defaultConfig : Config
defaultConfig =
    { ripple = False
    }


{-| Properties for Button options.
-}
type alias Property m =
    Options.Property Config m


{-| Set button to ripple when clicked.
-}
ripple : Property m
ripple =
    (\options -> { options | ripple = True })
        |> Internal.option


{-| Set button to "disabled".
-}
disabled : Property m
disabled =
    Internal.attribute <| Html.Attributes.disabled True


{-| Plain, uncolored button (default).
-}
plain : Property m
plain =
    Options.nop


{-| Color button with primary or accent color depending on button type.
-}
colored : Property m
colored =
    cs "mdl-button--colored"


{-| Color button with primary color.
-}
primary : Property m
primary =
    cs "mdl-button--primary"


{-| Color button with accent color.
-}
accent : Property m
accent =
    cs "mdl-button--accent"


{-| Sets the type of the button e.g.

    Button.render ...
      [ Button.type' "submit"
      ]
      [ ... ]
-}
type' : String -> Property m
type' =
    Html.Attributes.type' >> Internal.attribute


{-| Component view function.
-}
view : (Msg -> m) -> Model -> List (Property m) -> List (Html m) -> Html m
view lift model config html =
    let
        summary =
            Internal.collect defaultConfig config

        listeners =
            Options.many
                [ Ripple.down lift "mousedown"
                , Ripple.down lift "touchstart"
                , Ripple.up lift "touchcancel"
                , Ripple.up lift "mouseup"
                , Ripple.up lift "blur"
                , Ripple.up lift "mouseleave"
                ]
    in
        Internal.apply summary
            button
            [ cs "mdl-button"
            , cs "mdl-js-button"
            , cs "mdl-js-ripple-effect" `when` summary.config.ripple
            , listeners
            ]
            [ Helpers.blurOn "mouseup"
            , Helpers.blurOn "mouseleave"
            , Helpers.blurOn "touchend"
            ]
            (if summary.config.ripple then
                List.concat
                    [ html
                    , [ Html.App.map lift <|
                            Ripple.view'
                                [ class "mdl-button__ripple-container" ]
                                model
                      ]
                    ]
             else
                html
            )


{-| From the
[Material Design Specification](https://www.google.com/design/spec/components/buttons.html#buttons-flat-buttons):

> Flat buttons are printed on material. They do not lift, but fill with color on
> press.
>
> Use flat buttons in the following locations:
>
>  - On toolbars
>  - In dialogs, to unify the button action with the dialog content
>  - Inline, with padding, so the user can easily find them

Example use (uncolored flat button, assuming properly setup model):

    import Material.Button as Button

    flatButton : Model -> Html
    flatButton model =
      Button.render Mdl [0] model.mdl
        [ Button.flat ]
        [ text "Click me!" ]

-}
flat : Property m
flat =
    Options.nop


{-| From the
[Material Design Specification](https://www.google.com/design/spec/components/buttons.html#buttons-raised-buttons):

> Raised buttons add dimension to mostly flat layouts. They emphasize functions
> on busy or wide spaces.
>
> Raised buttons behave like a piece of material resting on another sheet –
> they lift and fill with color on press.

Example use (colored raised button, assuming properly setup model):

    import Material.Button as Button

    raisedButton : Model -> Html
    raisedButton model =
      Button.render Mdl [0] model.mdl
        [ Button.raised ]
        [ text "Click me!" ]

-}
raised : Property m
raised =
    cs "mdl-button--raised"


{-| Floating Msg Button. From the
[Material Design Specification](https://www.google.com/design/spec/components/buttons-floating-action-button.html):

> Floating action buttons are used for a promoted action. They are distinguished
> by a circled icon floating above the UI and have motion behaviors that include
> morphing, launching, and a transferring anchor point.
>
> Floating action buttons come in two sizes:
>
>  - Default size: For most use cases
>  - Mini size: Only used to create visual continuity with other screen elements

This constructor produces the default size, use `minifab` to get the mini-size.

Example use (colored with a '+' icon):

    import Material.Button as Button
    import Material.Icon as Icon

    fabButton : Model -> Html
    fabButton model =
      Button.render Mdl [0] model.mdl
        [ Button.fab ]
        [ Icon.i "add" ]
-}
fab : Property m
fab =
    cs "mdl-button--fab"


{-| Mini-sized variant of a Floating Msg Button; refer to `fab`.
-}
minifab : Property m
minifab =
    cs "mdl-button--mini-fab"


{-| The [Material Design Lite implementation](https://www.getmdl.io/components/index.html#buttons-section)
also offers an "icon button", which we
re-implement here. See also
[Material Design Specification](http://www.google.com/design/spec/components/buttons.html#buttons-toggle-buttons).
Example use (no color, displaying a '+' icon):

    import Material.Button as Button
    import Material.Icon as Icon

    iconButton : Html
    iconButton =
      Button.render Mdl [0] model.mdl
        [ Button.icon ]
        [ Icon.i "add" ]
-}
icon : Property m
icon =
    cs "mdl-button--icon"



-- PART


type alias Container c =
    { c | button : Indexed Model }


set : Indexed Model -> Container c -> Container c
set x y =
    { y | button = x }


{-| Component render.  Below is an example, assuming boilerplate setup as
indicated in `Material` and a user message `PollMsg`.

    Button.render Mdl [0] model.mdl
      [ Button.raised
      , Button.ripple
      , Options.onClick PollMsg
      ]
      [ text "Fetch new" ]
-}
render :
    (Material.Msg (Container c) m -> m)
    -> Parts.Index
    -> Container c
    -> List (Property m)
    -> List (Html m)
    -> Html m
render lift =
    Parts.create
        (Internal.inject view lift)
        (Parts.generalize update)
        .button
        set
        Ripple.model
        (Material.Internal >> lift)
