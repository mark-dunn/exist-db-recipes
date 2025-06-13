(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/html-templating" ;

(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="urn:recipes/config" at "config.xqm";
import module namespace app="urn:recipes/app" at "app.xql";


(:
http://exist.2174344.n4.nabble.com/Confused-about-xform-betterform-usage-td4661167.html
:)
(:declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";:)

(:
http://localhost:8080/exist/apps/betterform/Status.xhtml

acceptContentTypePattern

application/xhtml\+html

Based on this property, the XFormsFilter decide if should start XForms processing. Value can be 'all_xml' (WebFactory.ALL_XML_TYPES) to accept all xml content types or a reg expression to allow only certain ones.

:)

(: original (default) version :)
declare option exist:serialize "method=html5 media-type=text/html enforce-xhtml=yes";

(: returns nothing!! :)
(:declare option exist:serialize "method=xhtml media-type=text/html indent=yes";:)

(:
DOES NOT WORK

declare option exist:serialize "method=html5 media-type=application/xhtml+html";
:)



let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:integer) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
    
    
    (: using this version instead reveals that the function {$restxq}/recipes can't be found 
    
    error:
    
    exerr:ERROR Type mismatch: the actual type of parameter 4 does not match the type declared in the signature of function: templates:call-by-introspection($node as element(), $parameters as map, $model as map, $fn as function) item()*. Required type: function, got element(). [at line 188, column 74, source: C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
In function:
	templates:call-by-introspection(element(), map, map, function) [187:28:C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
	templates:call(item(), element(), map) [143:37:C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
	templates:process(node()*, map) [131:51:C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
	templates:process(node()*, map) [88:9:C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
	templates:apply(node()+, function, map?, map?) [78:5:C:\Mark\Website\eXist-db\webapp\WEB-INF\data\expathrepo\shared-0.4.0\content\templates.xql]
    
    :)
    (:let $f := fn:function-lookup(xs:QName($functionName), $arity )
    return if (exists($f)) then $f 
    else (<error>ERROR: can't find {$functionName}</error>) :)
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config)