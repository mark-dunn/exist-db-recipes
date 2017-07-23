xquery version "1.0";

declare namespace r="http://ns.datacraft.co.uk/recipe";
declare option exist:serialize "method=xhtml media-type=text/xml indent=yes process-xsl-pi=no";

let $new := request:get-parameter('new', '')
let $id := request:get-parameter('id', '')
let $data-collection := '/db/apps/recipes/data/recipes'
let $recipe := collection($data-collection)/r:recipe[r:id/text() = $id]

let $resource := if ($new = 'true') 
    then 'save-new.xq' 
    else 'update.xq'

(: Put in the appropriate file name.  Use new-instance.xml for new forms and get the data
   from the data collection for updates.  :)
let $file := if ($new = 'true') 
    then 'new-instance.xml'
    else concat('../data/recipes/', $id, '.xml')

let $form := 
<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xf="http://www.w3.org/2002/xforms" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:r="http://ns.datacraft.co.uk/recipe">
    <head>
       <title>Edit Item</title>
       <link rel="stylesheet" type="text/css" href="../resources/css/style.css" />
       <style type="text/css">
       <![CDATA[
       @namespace xf url("http://www.w3.org/2002/xforms");

       body {
           font-family: Helvetica, Arial, Verdana, sans-serif;
       }

       .term-name .xforms-value {width: 50ex;}
       .definition .xforms-value {
           height: 5em;
           width: 600px;
       }
           
       /* align the labels but not the save label */
       xf|output xf|label, xf|input xf|label, xf|textarea xf|label, xf|select1 xf|label {
           display: inline-block;
           width: 14ex;
           text-align: right;
           vertical-align: top;
           margin-right: 1ex;
           font-weight: bold;
       }

       xf|input, xf|select1, xf|textarea, xf|ouptut {
           display: block;
           margin: 1ex;
       }
       ]]>
       </style>
       <xf:model id="recipes-model">
           <xf:instance xmlns:r="http://ns.datacraft.co.uk/recipe" src="{$file}" id="this-recipe"/>
           
           
           <!-- empty <ingredient> to insert -->
           <xf:instance xmlns:r="http://ns.datacraft.co.uk/recipe" id="new-ingredient">
           <r:ingredient xmlns:r="http://ns.datacraft.co.uk/recipe"/>
           </xf:instance>
                 
           <!-- empty <step> to insert -->
           <xf:instance xmlns:r="http://ns.datacraft.co.uk/recipe" id="new-step">
           <r:step xmlns:r="http://ns.datacraft.co.uk/recipe"/>
           </xf:instance>

            <!-- http://www.ibm.com/developerworks/library/x-xformstipalerts/ -->
            <xf:bind nodeset="/r:recipe/r:ingredients/r:ingredient" id="message-test"/>
            
            <!-- replace="all" replaces the entire page with the response
            
            replace="instance" replaces only the instance in the edit form
            -->

            <xf:submission id="save" method="post" resource="{$resource}" instance="this-recipe" replace="all">
            <xf:action ev:event="xforms-submit-error">
    <xf:message>Submit Error! Resource-uri: <xf:output value="event('resource-uri')"/>
                Response-reason-phrase: <xf:output value="event('response-reason-phrase')"/>
    </xf:message>
  </xf:action>
            </xf:submission>
       </xf:model>
    </head>
    <body>
                <h1>Edit Recipe: "{$recipe/r:title/text()}"</h1>
                
                <div class="dcContentBlock">
                
                                {if ($id) then
                    <xf:output ref="@id" class="id">
                        <xf:label>ID:</xf:label>
                    </xf:output>
                else ()}
                
                <xf:input ref="/r:recipe/r:title" class="recipe-name">
                    <xf:label>Recipe Name:</xf:label>
                </xf:input>     
                
 <!--                http://www.w3.org/TR/2007/REC-xforms-20071029/#ui-repeat -->
               <xf:repeat id="ingredients-repeat" nodeset="/r:recipe/r:ingredients/r:ingredient">
                    <xf:input ref="." class="ingredient">
                        <xf:label>Ingredient:</xf:label>
                    </xf:input>   
                    
                    <xf:trigger>
                    <xf:label>Add ingredient</xf:label>
                    <xf:insert ev:event="DOMActivate" nodeset="/r:recipe/r:ingredients/r:ingredient" at="index('ingredients-repeat')" position="after" origin="instance('new-ingredient')"/>                       
                </xf:trigger>
                          

                     <xf:trigger>
                     <xf:label>Up</xf:label>
                     <!-- xf:action groups a sequence of actions -->
                     <xf:action ev:event="DOMActivate" if="index('ingredients-repeat') != 1">
                     <!-- insert changes "focus" index to the newly inserted node -->
                        <xf:insert
                   nodeset="/r:recipe/r:ingredients/r:ingredient"  
                   at="index('ingredients-repeat')-1"
                   position="before"
                   origin="/r:recipe/r:ingredients/r:ingredient[index('ingredients-repeat')]"/>
                         <!-- push focus back to original node -->
                         <xf:setindex repeat="ingredients-repeat" index="index('ingredients-repeat') + 2"/>
                         <xf:setfocus control="ingredients-repeat"/>
                         <xf:delete nodeset="/r:recipe/r:ingredients/r:ingredient" at="index('ingredients-repeat')"/>
                         <xf:rebuild model="recipes-model"/>
                   </xf:action>
                    </xf:trigger>
 
                    <xf:trigger>
                     <xf:label>Down</xf:label>
                     <!-- xf:action groups a sequence of actions 
                     
                     tried position() instead of index('ingredients-repeat') but didn't work
                     possibly because focus was on a different row from where 'Down' was clicked
                     -->
                     <xf:action ev:event="DOMActivate" if="index('ingredients-repeat') != count(/r:recipe/r:ingredients/r:ingredient)">
                     <!-- insert changes "focus" index to the newly inserted node 
                     
                     weirdly, this doesn't work properly using the REST URL
                     -->
                        <xf:insert
                   nodeset="/r:recipe/r:ingredients/r:ingredient"  
                   at="index('ingredients-repeat')+1"
                   position="after"
                   origin="/r:recipe/r:ingredients/r:ingredient[index('ingredients-repeat')]"/>
                          <!-- push focus back to original node -->
                         <xf:setindex repeat="ingredients-repeat" index="index('ingredients-repeat') - 2"/>
                        <xf:setfocus control="ingredients-repeat"/>
                         <xf:delete nodeset="/r:recipe/r:ingredients/r:ingredient" at="index('ingredients-repeat')"/>
                         
                   </xf:action>
                    </xf:trigger>
 
                 <xf:trigger>
                    <xf:label>Delete ingredient</xf:label>
                    <xf:delete ev:event="DOMActivate" nodeset="/r:recipe/r:ingredients/r:ingredient" at="index('ingredients-repeat')"/>
                </xf:trigger>
                    
                    
                </xf:repeat>
                
                
                  
  

                <xf:repeat id="method-repeat" nodeset="/r:recipe/r:method/r:step">
                    <xf:input ref="." class="step">
                        <xf:label>Step:</xf:label>
                    </xf:input>    
                    
                    <xf:trigger>
                    <xf:label>Add step</xf:label>
                   <xf:insert ev:event="DOMActivate" nodeset="/r:recipe/r:method/r:step" at="index('method-repeat')" position="after" origin="instance('new-step')"/>
                 </xf:trigger>

               <xf:trigger>
                    <xf:label>Delete step</xf:label>
                    <xf:delete ev:event="DOMActivate" nodeset="/r:recipe/r:method/r:step" at="index('method-repeat')"/>
                </xf:trigger>
                </xf:repeat>
                
                          
 
                <xf:submit submission="save">
                    <xf:label>Save</xf:label>
                </xf:submit>

                </div>
                
                <div class="dcContentBlock">
                <p><a href="../index.html">Home</a></p>
                </div>
    </body>
</html>
      
(: XSLTForms is a bit broken (can't handle the Up/Down logic) :)      
(:let $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/exist/rest/db/apps/xsltforms/xsltforms.xsl"'}
          
let $debug := processing-instruction xsltforms-options {'debug="yes"'}
          

return ($xslt-pi, $debug, $form) :)

return $form