xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

<html>
   <head>
      <title>Recipes</title>
       <link rel="stylesheet" type="text/css" href="resources/css/style.css"/>
     </head>
    <body>
       <h1>Recipes</h1>
       
       <div class="dcContentBlock">
        <form method="get" action="search/search.xq">
            <input name="q" type="text" value="" size="30"/>
            <input type="submit" value="Search"/>
        </form>

       </div>
       <div class="dcContentBlock">
          <ul>
            <li>
                <a href="edit/edit.xq?new=true">Create New Recipe</a>
            </li>
            <li>
                <a href="search/search.xq?q=gravy">Search for "gravy"</a>
            </li>
            <li>
                <a href="admin/reindex.xq">Reindex the collection</a>
            </li>
        </ul>

       </div>
       
       <div class="dcContentBlock">
       <ol class="recipe-list">{
         for $item in collection('/db/apps/recipes/data/recipes')/r:recipe
            let $item-name := $item/r:title/text()
            order by $item-name
            return
               <li><a href="views/view-item.xq?id={$item/@id}">{$item-name}</a></li>
      }</ol>
      </div>
      
    </body>
</html>