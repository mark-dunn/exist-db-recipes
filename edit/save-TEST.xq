xquery version "3.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $app-collection := '/db/apps/recipes'
let $data-collection := '/db/apps/recipes/data/recipes'
 
(: log into the collection :)
let $login := xmldb:login($data-collection, 'admin', '0verc00k')


return
<html>
    <head>
       <title>Save Confirmation</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css" />
    </head>
    <body>
        <h1>Save Confirmation</h1>
        <div class="dcContentBlock">
        <p>TEST</p>
        </div>
        <div class="dcContentBlock">
        <p><a href="../index.html">Home</a> &gt; <a href="../views/list-items.xq">List all Recipes</a> </p>
        </div>
    </body>
</html>