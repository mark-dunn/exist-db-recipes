xquery version "3.0";

module namespace app="http://localhost:8080/exist/apps/recipes/templates";


import module namespace xrest="http://exquery.org/ns/restxq/exist" at "java:org.exist.extensions.exquery.restxq.impl.xquery.exist.ExistRestXqModule";


(:import module namespace templates="http://exist-db.org/xquery/templates" ;:)
import module namespace config="http://localhost:8080/exist/apps/recipes/config" at "config.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace r="http://ns.datacraft.co.uk/recipe";

declare variable $app:data := $config:app-root || "/data/recipes";
declare variable $app:u := "admin";
declare variable $app:p := "###REPLACE###";



(:~
 : List all recipes and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/recipes")
    %rest:produces("application/xml", "text/xml")
function app:all-recipes() {
    <r:recipes xmlns:xforms="http://www.w3.org/2002/xforms">
    {
        collection($app:data)/r:recipe
    }
    </r:recipes>
};

(:~
 : Clear recipes.
 :)
declare
    %rest:GET
    %rest:path("/clear")
    %rest:produces("application/xml", "text/xml")
function app:clear-recipes() {
    <r:recipes xmlns:xforms="http://www.w3.org/2002/xforms">
        <r:recipe>
             <r:id/>
            <r:title/>
             <r:ingredients>
                <r:ingredient/>
             </r:ingredients>
             <r:method>
               <r:step/>
             </r:method>
        </r:recipe>
    </r:recipes>
};


(:~
 : Retrieve a recipe identified by uuid.
 :)
declare 
    %rest:GET
    %rest:path("/recipes/{$id}")
function app:get-recipe($id as xs:string*) {
    collection($app:data)/r:recipe[r:id/text() = $id]
};

(:~
 : Search recipes using a given field and a (lucene) query string.
 :)
declare 
    %rest:GET
    %rest:path("/search-recipes")
    %rest:form-param("query", "{$query}", "")
    %rest:form-param("field", "{$field}", "ingredient")
function app:search-recipes($query as xs:string*, $field as xs:string*) {
    let $log := util:log("DEBUG", "Searching for '" || $query || "' in field '" || $field || "'" )
    return
    <r:recipes xmlns:xforms="http://www.w3.org/2002/xforms">
    {
        if ($query != "") then

            switch ($field)
                case "ingredient" return
(:                    collection($app:data)/r:recipe[ descendant::r:ingredient[ft:query(., $query)] ] :)
                    collection($app:data)/r:recipe[ngram:contains(descendant::r:ingredient, $query)] 

                case "title" return
(:                    collection($app:data)/r:recipe[ft:query(r:title, $query)]:)
                    collection($app:data)/r:recipe[ngram:contains(r:title, $query)]
                default return
(:                    collection($app:data)/r:recipe[ft:query(descendant::*, $query)]:)
                    collection($app:data)/r:recipe[ngram:contains(descendant::*, $query)] 
        else
            collection($app:data)/r:recipe
    }
    </r:recipes>
};

(:~
 : Update an existing recipe or store a new one. The address XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/recipe")
function app:create-or-edit-recipe($content as document-node()) as element() {
    let $id := ($content/r:recipe/r:id/text(), util:uuid())[1]
    let $data :=
        <r:recipe>
            <r:id>{$id}</r:id>
        { $content/r:recipe/*[not(self::r:id)] }
        </r:recipe>
    let $log := util:log("DEBUG", "Storing data into " || $app:data)
    let $login := xmldb:login($app:data, $app:u, $app:p)
    let $stored := xmldb:store($app:data, $id || ".xml", $data)
    return <success/>
};

(:~
 : Create an ID for a recipe if it has not got one already
 : 
 : Use %output REST paarameter to return a string
 : (overriding the default application/xml return content type)
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/get-id")
    %output:method("text")
function app:create-or-get-id($content as document-node()) as xs:string {
    let $id := $content/r:id
    let $new-id := ($id/text(), util:uuid())[1]
    return $new-id
};

(:~
 : Delete an address identified by its uuid.
 
 : according to Saxon-JS documentation, response body is either a document node, or text
 : https://www.saxonica.com/saxon-js/documentation/index.html#!development/http
 : BUT possible bug
 : if anything other than XML is returned we get an error 
 : 405 HTTP method GET is not supported by this URL
 :)
declare
    %rest:GET
    %rest:path("/delete/{$id}")
function app:delete-recipe-no-param($id as xs:string*) {
    let $deleted := xmldb:remove($app:data, $id || ".xml")
    return <deleted/>
};


(:~
 : Delete an address identified by its uuid.
 
 : for some reason does not work with DELETE method!
 : Perhaps should not use form parameters?
 :)
declare
    %rest:PUT("{$id}")
    %rest:path("/delete-recipe")
    %rest:produces("application/xml")
function app:delete-recipe($id as document-node()) {
    let $login := xmldb:login($app:data, $app:u, $app:p)
    let $deleted := xmldb:remove($app:data, $id/r:id/text() || ".xml") 
    return <deleted/>
};


(:~
 : Reindex the recipe collection
 :)
declare
    %rest:GET
    %rest:path("/reindex-recipes")
    %rest:produces("application/xml", "text/xml")
function app:reindex-recipes() {
    let $login := xmldb:login($app:data, 'admin', '3mU3ls@doz')
    return 
    <reindex-status>
    {
        xmldb:reindex($app:data)
    }
    </reindex-status>
};



(:~
 : List resource functions from the restxq.registry
 :)
declare
    %rest:GET
    %rest:path("/restxq-functions")
    %rest:produces("application/xml", "text/xml")
function app:debug-restxq-registry() {
    rest:resource-functions()
};

(:~
 : get namespace URI
 
 DOESN'T WORK, name() and namespace-uri() return nothing
 :)
(:declare
    %rest:PUT("{$field}")
    %rest:path("/get-namespace")
function app:debug-get-namespace($field as node()*) {
        let $log := util:log("DEBUG", "Namespace of " || $field/name() || " is " || $field/namespace-uri() )
        return ()
};
:)

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy TEST template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};


(:xrest:register-module(xs:anyURI("app.xql")):)