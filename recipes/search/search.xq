xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data-collection := '/db/apps/recipes/data/recipes'
let $q := request:get-parameter('q', "")

(: put the search results into memory using the eXist any keyword ampersand equals comparison :)
let $search-results := collection($data-collection)/r:recipe[ft:query(descendant::*, $q)]
let $count := count($search-results)


return
<html>
    <head>
       <title>Recipe Search Results</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
     </head>
     <body>
        <h1>Recipe Search Results</h1>
        <div class="dcContentBlock">
        <p><b>Search results for:</b> &quot;{$q}&quot; <b>In Collection:</b> {$data-collection}</p>
        <p><b>Terms Found:</b> {$count}</p>
     <ol>{
           for $recipe in $search-results
              let $id := $recipe/r:id/text()
              let $recipe-name := $recipe/r:title/text()
              order by upper-case($recipe-name)
          return
            <li>
               <a href="../views/view-item.xq?id={$id}">{$recipe-name}</a>
            </li>
      }</ol>

        </div>
        <div class="dcContentBlock">
            <p><a href="search-form.html">New Search</a></p>
            <p><a href="../index.html">Home</a></p>
        </div>

   </body>
</html>