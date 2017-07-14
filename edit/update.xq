xquery version "3.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
let $data-collection := '/db/apps/recipes/data/recipes'
 
(: get the form data that has been "POSTed" to this XQuery :)
let $item := request:get-data()
 
(: log into the collection :)
let $login := xmldb:login($data-collection, 'admin', '0verc00k')



(: get the id out of the posted document :)
let $id := $item/r:recipe/@id 



let $file := concat($id, '.xml') 
 
(: save the new file, overwriting the old one :)
let $store := xmldb:store($data-collection, $file, $item)

(: 

{$id/text()} rather than just $id 

to prevent error about attribute node not being allowed 

:)
return
<html>
    <head>
       <title>Update Confirmation</title>
    </head>
    <body>
    <h1>Update Confirmation</h1>
   
        <p>Recipe {$id/text()} has been updated.</p>
    <p><a href="../index.html">Home</a> &gt; <a href="../views/list-items.xq">List all Recipes</a> </p>
   </body>
</html>