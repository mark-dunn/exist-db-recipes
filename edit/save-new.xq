xquery version "3.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $app-collection := '/db/apps/recipes'
let $data-collection := '/db/apps/recipes/data/recipes'
 
(: get the form data that has been "POSTed" to this XQuery :)
let $item := request:get-data()
 
(: get the next ID from the next-id.xml file :)
let $next-id-file-path := concat($app-collection,'/edit/next-id.xml')
let $id := doc($next-id-file-path)/data/next-id/text() 

let $file := concat($id, '.xml')
let $file-path := concat($data-collection, '/', $file)



(: logs into the collection :)
let $login := xmldb:login($app-collection, 'admin', '0verc00k')

(: create the new file with a still-empty id element :)
let $store := xmldb:store($data-collection, $file, $item) 

(: add the correct ID to the new document we just saved :)
(: NOT WORKING - DIDN'T LIKE ATTRIBUTE - WHY?? :)
(:let $update-id :=  update replace doc($file-path)/r:recipe/@id with string($id):)
let $update-id :=  update replace doc($file-path)/r:recipe/r:id/text() with $id

let $title := doc($file-path)/r:recipe/r:title/text()

(: update the next-id.xml file :)
let $new-next-id :=  update replace doc($next-id-file-path)/data/next-id/text() with ($id + 1)



return
<html>
    <head>
       <title>Save Confirmation</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css" />
    </head>
    <body>
        <h1>Save Confirmation</h1>
        <div class="dcContentBlock">
        <p>Recipe '{$title}' has been saved. (File '{$file-path}' in collection)</p>
        </div>
        <div class="dcContentBlock">
        <p><a href="../index.html">Home</a> &gt; <a href="../views/list-items.xq">List all Recipes</a> </p>
        </div>
    </body>
</html>