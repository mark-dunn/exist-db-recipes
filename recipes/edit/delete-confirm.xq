xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $id := request:get-parameter("id", "")

let $data-collection := '/db/apps/recipes/data/recipes'
let $doc := concat($data-collection, '/', $id, '.xml')

return
<html>
    <head>
        <title>Delete Confirmation</title>
        <link rel="stylesheet" type="text/css" href="../resources/css/style.css" />
       <style type="text/css">
        <![CDATA[
        .warn {background-color: silver; color: black; font-size: 16pt; line-height: 24pt; padding: 5pt; border: solid 2px black;}
        ]]>
        </style>
    </head>
    <body>
        
        <h1>Are you sure you want to delete this recipe?</h1>
        
        <div class="dcContentBlock">
        <p><strong>Name:</strong> {doc($doc)/r:recipe/r:title/text()}</p>
        <p><strong>Path:</strong> {$doc}</p>
        <p><a class="warn" href="delete.xq?id={$id}">Yes - Delete This Term</a></p>
        <p><a class="warn" href="../views/view-item.xq?id={$id}">Cancel (Back to View Item)</a></p>
        </div>
        
        <div class="dcContentBlock">
        <p><a href="../index.html">Recipes Home</a> &gt; <a href="../views/list-items.xq">List Recipes</a></p>
        </div>
    </body>
</html>