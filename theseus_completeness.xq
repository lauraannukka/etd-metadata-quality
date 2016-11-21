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
    else if (local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'issued') then
      1
    else if (local-name($element) eq 'field' and $element/@element eq 'organization') then
			1
    else if(local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'available') then
      1
    else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'urn') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'description' and $element/@qualifier eq 'abstract') then
			1
		else if ((local-name($element) eq 'field' and $element/@element eq 'subject') or (local-name($element) eq 'field' and $element/@element eq 'keyword')) then
		  1 
    else if (local-name($element) eq 'field' and $element/@element eq 'programme') then
			1 
    else if(local-name($element) eq 'field' and $element/@element eq 'rights') then
      1
		else if (local-name($element) eq 'field' and $element/@element eq 'publisher') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'format' and ($element/@qualifier eq 'extent' or $element/@qualifier eq 'size')) then
			1    
    else if (local-name($element) eq 'file') then
			1  
    else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'uri') then
			1     
  	else (0)
};

let $scores:=
<scores>{
  for $record in metadata
  where $record/field[@element='type' and @qualifier eq 'ontasot']
  
  return
  <record>
  <id>{data($record/field[@element eq 'identifier' and @qualifier eq 'uri']/@value)}</id>
  <ontaso1>{data($record/field[@element eq 'type' and @qualifier eq 'ontasot'][1]/@value)}</ontaso1>
  <ontaso2>{data($record/field[@element eq 'type' and @qualifier eq 'ontasot'][2]/@value)}</ontaso2>
  <ontaso3>{data($record/field[@element eq 'type' and @qualifier eq 'ontasot'][3]/@value)}</ontaso3>
  <tallennuspvm>{data($record/field[@element eq 'date' and @qualifier eq 'accessioned']/@value)}</tallennuspvm>
  <score>{round-half-to-even((sum((
  local:calculate-score($record/field[@element eq 'contributor' and @qualifier eq 'author'][1]),
  local:calculate-score($record/field[@element eq 'title'][1]),
  local:calculate-score($record/field[@element eq 'type' and @qualifier eq 'ontasot'][1]),
  local:calculate-score($record/field[@element eq 'language'][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'issued'][1]),
  local:calculate-score($record/field[@element eq 'organization'][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'available'][1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'urn'][1]),
  local:calculate-score($record/field[@element eq 'description' and @qualifier eq 'abstract'][1]),
  local:calculate-score($record/field[@element eq 'subject' or @element eq 'keyword'][1]),
  local:calculate-score($record/field[@element eq 'programme'][1]),
  local:calculate-score($record/field[@element eq 'rights'][1]),
  local:calculate-score($record/field[@element eq 'publisher'][1]),
  local:calculate-score($record/field[@element eq 'format' and @qualifier eq 'extent' or @qualifier eq 'size'][1]),
  local:calculate-score($record/file[1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'uri'][1])  
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
let $ontaso := $record/ontaso1
let $ontaso2 := $record/ontaso2
let $ontaso3 := $record/ontaso3
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