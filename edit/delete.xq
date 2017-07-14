xquery version "1.0";

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $data-collection := '/db/apps/recipes/data/recipes'
 
(: get the id parameter from the URL :)
let $id := request:get-parameter('id', '')

(: log into the collection :)
let $login := xmldb:login($data-collection, 'admin', '0verc00k')

(: construct the filename from the id :)
let $file := concat($id, '.xml')

(: delete the file :)
let $store := xmldb:remove($data-collection, $file)

return
<html>
    <head>
        <title>Delete Recipe</title>
        <style type="text/css">
            <![CDATA[
               .warn  {background-color: silver; color: black; font-size: 16pt; line-height: 24pt; padding: 5pt; border:solid 2px black;}
            ]]>
        </style>
    </head>
    <body>
        <h1>Recipe ID "{$id}" has been removed.</h1>
        <p><a href="../index.html">Recipes Home</a> &gt; <a href="../views/list-items.xq">List Recipes</a>
        </p>
    </body>
</html>