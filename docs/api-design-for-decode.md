# api design question for `decode`

For `encode`, the JS library throws errors for invalid values, so using result there is obvious. 

```elm
Sqids.encode : List Int -> Result EncodeError String
Sqids.encode [userId, postId] = "n3qa"
```

But for `decode`, it only returns empty Arrays.

So the first idea is `decode : String -> List Int`

```elm
case Sqids.LikeJs.decode string of
    [] -> 
        -- string might have been empty
        -- string might have contained an invalid character
    [ userId, postId ] ->
        -- my current use case expects two positive ints
    _ ->
        -- too many values, wrong kind of id
```

When compared to `decode : String -> Result DecodeError (List Int)`

My gut feeling is that I want it to return a result, too.  
But when using it, it feels like it does not add much value, only more boilerplate.  
In my use case I want to decode two numbers, and every other result is an error in my program.

```elm
case Sqids.Gutfeeling.decode string of
    Err EmptyString -> -- ...
    Err CharacterNotInAlphabet invalidChar -> ---
    Ok [] -> -- impossible case
    Ok [ userId, postId ] -> -- use the values
    Ok _ -> -- too few or too many values, wrong kind of id
```

So maybe a nonempty list variant would be best? But I don't want to rely on a specific third party package, so maybe `decode : String -> Result DecodeError (Int, List Int)`

```elm
case Sqids.NeList.decode string of
    Err EmptyString -> -- ...
    Err CharacterNotInAlphabet invalidChar -> ---
    Ok ( userId, [ postId ]) -> -- use the values
    Ok _ -> -- too few or too many values, wrong kind of id
```

And I'm not sure if this kind of noempty list would be confusing to first time users.
Would this be improved by exposing a type alias?

To me, using the `LikeJs` variant feels most natural.

Another option could be to create 3 different expose modules and let the users decide which they like best? Or would this make the design too convoluted?
