xquery version "3.0";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace r="http://ns.datacraft.co.uk/recipe";

(: https://exist-db.org/exist/apps/doc/oxygen :)
let $functions := rest:resource-functions()
return $functions