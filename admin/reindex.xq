xquery version "1.0";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data-collection := '/db/apps/recipes/data/recipes'

let $login := xmldb:login($data-collection, 'admin', '0verc00k')
let $start-time := util:system-time()
let $reindex := xmldb:reindex($data-collection)
let $runtime-ms := ((util:system-time() - $start-time)
                   div xs:dayTimeDuration('PT1S'))  * 1000 

return
<html>
    <head>
       <title>Reindex</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
    </head>
    <body>
    <h1>Reindexing...</h1>
    {
    if (not($login)) 
    then <div class="dcContentBlock"><p>LOGIN FAILED!</p></div>
    else ()
    }
    
    <div class="dcContentBlock">
    <p>The index for {$data-collection} was updated in  {$runtime-ms} milliseconds.</p>
    <p><a href="../index.html">Home</a></p>
    </div>
    </body>
</html>