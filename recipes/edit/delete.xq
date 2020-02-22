xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $data-collection := '/db/apps/recipes/data/recipes'
 
(: get the id parameter from the URL :)
let $id := request:get-parameter('id', '')

(: log into the collection :)
let $login := xmldb:login($data-collection, 'admin', '0verc00k')

(: construct the filename from the id :)
let $file := concat($id, '.xml')

(: Wanted to get the file to remove by reading the collection, but this doesn't work :)
(:let $file := collection($data-collection)[/r:recipe/r:id/text() = $id]:)

(: delete the file :)
let $store := xmldb:remove($data-collection, $file)

return
<html>
    <head>
        <title>Delete Recipe</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
     </head>
    <body>
        <h1>Recipe ID "{$id}" has been removed.</h1>
        <div class="dcContentBlock">
        <p><a href="../index.html">Recipes Home</a> &gt; <a href="../views/list-items.xq">List Recipes</a>
        </p>
        </div>
    </body>
</html>