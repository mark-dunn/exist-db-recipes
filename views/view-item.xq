xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $id := request:get-parameter("id", "")
let $recipe := collection('/db/apps/recipes/data/recipes')/r:recipe[@id=$id]

return
<html>
   <head>
      <title>Recipe "{$recipe/r:title/text()}"</title>
      <link rel="stylesheet" type="text/css" href="../resources/css/style.css"/>
    </head>
    <body>
       <h1>Recipe "{$recipe/r:title/text()}"</h1>
       <div class="ingredients dcContentBlock">
         <h2>Ingredients</h2>
         <ul>
         {
         for $ingredient in $recipe/r:ingredients/r:ingredient/text()
            return
                <li>{$ingredient}</li>
         }
         </ul>
       </div>
       <div class="method dcContentBlock">
         <h2>Method</h2>
          <ul>
         {
         for $step in $recipe/r:method/r:step/text()
            return
                <li>{$step}</li>
         }
         </ul>
       </div>
       
       <div class="dcContentBlock">
       <form method="get" action="../edit/delete-confirm.xq">
            <input name="id" type="hidden" value="{$id}" />
            <input type="submit" value="Delete"/>
        </form>
        </div>

       <div class="dcContentBlock">
       <p><a href="../edit/edit.xq?id={$id}">Edit this recipe</a></p>
       <p><a href="../index.xq">Home</a></p>
        </div>
        
     </body>
</html>