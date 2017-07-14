xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

<html>
   <head>
      <title>List of recipes</title>
      <link rel="stylesheet" type="text/css" href="../resources/css/style.css" />
       
    </head>
    <body>
       <h1>Recipes</h1>
       <div class="dcContentBlock">
       <ol>{
         for $item in collection('/db/apps/recipes/data/recipes')/r:recipe
            let $item-name := $item/r:title/text()
            order by $item-name
            return
               <li><a href="view-item.xq?id={$item/@id}">{$item-name}</a></li>
      }</ol>
      </div>
      <div class="dcContentBlock">
        <p><a href="../index.html">Home</a></p>
      </div>

    </body>
</html>