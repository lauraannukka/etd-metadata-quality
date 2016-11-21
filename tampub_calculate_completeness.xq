declare option output:method "csv";
declare option output:csv "header=yes, separator=|";

declare function local:calculate-score($element as element()?) as xs:integer {
	 
		if (local-name($element) eq 'field' and $element/@element eq 'contributor' and $element/@qualifier eq 'author') then
			1
		else if (local-name($element) eq 'field' and $element/@element eq 'title') then
			1
		else if (local-name($element) eq 'field' and $element/@element eq 'type' and $element/@qualifier eq 'ontasot') then
			1
		else if (local-name($element) eq 'field' and $element/@element eq 'language') then
			1
		else if (local-name($element) eq 'field' and ($element/@element eq 'administrativeunit' or $element/@element eq 'faculty' or $element/@element eq 'department')) then 
	    1
		else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'urn') then
			1    
    else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'uri') then
			1    
    else if (local-name($element) eq 'field' and $element/@element eq 'description' and $element/@qualifier eq 'abstract') then
			1    
    else if (local-name($element) eq 'field' and $element/@element eq 'subject') then
			1  
    else if (local-name($element) eq 'field' and $element/@element eq 'subject' and ($element/@qualifier eq 'study' or $element/@qualifier eq 'degreeprogramme')) then
			1         
    else if (local-name($element) eq 'field' and ($element/@element eq 'date' and $element/@qualifier eq 'issued')) then
			1 
    else if(local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'available') then
    1
    else if (local-name($element) eq 'field' and $element/@element eq 'publisher') then
			1     
    else if (local-name($element) eq 'field' and $element/@element eq 'format' and $element/@qualifier eq 'extent') then
			1    
    else if (local-name($element) eq 'file') then
			1    
  	else (0)
};

let $scores:=
<scores>{
  for $record in /*:exportedRecords/*:record/*:metadata/*:metadata
  return
  <record>
  <id>{data($record/*:field[@element eq 'identifier' and @qualifier eq 'uri']/@value)}</id>
  <ontaso>{data($record/*:field[@element eq 'type' and @qualifier eq 'ontasot']/@value)}</ontaso>
  <tallennuspvm>{data($record/*:field[@element eq 'date' and @qualifier eq 'accessioned']/@value)}</tallennuspvm>
 
  <score>{round-half-to-even((sum((
  local:calculate-score($record/*:field[@element eq 'contributor' and @qualifier eq 'author'][1]),
  local:calculate-score($record/*:field[@element eq 'title'][1]),
  local:calculate-score($record/*:field[@element eq 'type' and @qualifier eq 'ontasot'][1]),
  local:calculate-score($record/*:field[@element eq 'language'][1]),
  local:calculate-score($record/*:field[@element eq 'administrativeunit'[1] or @element eq 'faculty'[1] or @element eq 'department'][1]),
  local:calculate-score($record/*:field[@element eq 'identifier' and @qualifier eq 'urn'][1]),
  local:calculate-score($record/*:field[@element eq 'identifier' and @qualifier eq 'uri'][1]),
  local:calculate-score($record/*:field[@element eq 'description' and @qualifier eq 'abstract'][1]),
  local:calculate-score($record/*:field[@element eq 'subject' and not(@qualifier)][1]),
  local:calculate-score($record/*:field[@element eq 'subject' and @qualifier eq 'study'[1] or @qualifier eq 'degreeprogramme'][1]),
  local:calculate-score($record/*:field[@element eq 'date' and @qualifier eq 'issued'][1]),
  local:calculate-score($record/*:field[@element eq 'publisher'][1]),
  local:calculate-score($record/*:field[@element eq 'format' and @qualifier eq 'extent'][1]),
  local:calculate-score($record/*:field[@element eq 'date' and @qualifier eq 'available'][1]),
  local:calculate-score($record/*:file[1])
  )  
) div 18),2)}
</score>

</record>
}</scores>

let $csv :=
<csv>{

for $record in $scores/record
let $quality := $record/score
let $id := $record/id 
let $ontaso := $record/ontaso
let $tallennus := substring-before($record/tallennuspvm,"-")

order by $quality ascending


return 

<record>
<score>{data($quality)}</score>
<id>{data($id)}</id>
<ontaso>{data($ontaso)}</ontaso>
<tallennuspvm>{data($tallennus)}</tallennuspvm>
</record>


}</csv>
return $csv