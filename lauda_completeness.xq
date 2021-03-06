declare option output:method "csv";
declare option output:csv "header=yes, separator=|";

declare function local:calculate-score($element as item()?) as xs:integer {
	 
		if (local-name($element) eq 'field' and $element/@element eq 'contributor' and $element/@qualifier eq 'author') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'programme') then
			1 
    else if (local-name($element) eq 'field' and $element/@element eq 'title') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'type' and $element/@qualifier eq 'ontasot') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'language') then
			1
    else if (local-name($element) eq 'field' and ($element/@element eq 'date' and $element/@qualifier eq 'issued')) then
			1 
    else if (local-name($element) eq 'field' and $element/@element eq 'contributor' and not($element/@qualifier)) then
			1 
    else if(local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'available') then
    1
		else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'urn') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'description' and $element/@qualifier eq 'abstract') then
			1    
    else if (local-name($element) eq 'field' and $element/@element eq 'subject') then
			1  
    else if (local-name($element) eq 'field' and $element/@element eq 'rights') then
			1 
    else if (local-name($element) eq 'field' and $element/@element eq 'publisher') then
			1 
    else if (local-name($element) eq 'field' and $element/@element eq 'format' and $element/@qualifier eq 'extent') then
			1 
    else if (local-name($element) eq 'file') then
			1  
    else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'uri') then
			1                
  	else (0)
};
  
let $diss_scores:=
<scores>{
  for $record in /juuri/record/metadata/metadata
  return
  <record>
  <id1>{data($record/field[@element eq 'identifier' and @qualifier eq 'uri']/@value)}</id1>
  <ontaso>{data($record/field[@element eq 'type' and @qualifier eq 'ontasot']/@value)}</ontaso>
  <tallennuspvm>{data($record/field[@element eq 'date' and @qualifier eq 'accessioned']/@value)}</tallennuspvm>
  <score>{round-half-to-even((sum((
  local:calculate-score($record/field[@element eq 'contributor' and @qualifier eq 'author'][1]),
  local:calculate-score($record/field[@element eq 'title'][1]),
  local:calculate-score($record/field[@element eq 'type' and @qualifier eq 'ontasot'][1]),
  local:calculate-score($record/field[@element eq 'language'][1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'urn'][1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'uri'][1]),
  local:calculate-score($record/field[@element eq 'description' and @qualifier eq 'abstract'][1]),
  local:calculate-score($record/field[@element eq 'subject'][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'issued'][1]),
  local:calculate-score($record/field[@element eq 'publisher'][1]),
  local:calculate-score($record/field[@element eq 'format' and @qualifier eq 'extent'][1]),
  local:calculate-score($record/field[@element eq 'contributor' and not(@qualifier)][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'available'][1]),
  local:calculate-score($record/field[@element eq 'rights'][1]),
  local:calculate-score($record/field[@element eq 'programme'][1]),
  local:calculate-score($record/file[1])
  )  
) div 18),2)}
</score>

</record>

}</scores>

let $thesis_scores:=
<scores>{
  for $record in /juuri/metadata
  return
  <record>
  <id2>{data($record/field[@element eq 'identifier' and @qualifier eq 'uri']/@value)}</id2>
  <ontaso>{data($record/field[@element eq 'type' and @qualifier eq 'ontasot']/@value)}</ontaso>
  <tallennuspvm>{data($record/field[@element eq 'date' and @qualifier eq 'accessioned']/@value)}</tallennuspvm>
  <score>{round-half-to-even((sum((
  local:calculate-score($record/field[@element eq 'contributor' and @qualifier eq 'author'][1]),
  local:calculate-score($record/field[@element eq 'title'][1]),
  local:calculate-score($record/field[@element eq 'type' and @qualifier eq 'ontasot'][1]),
  local:calculate-score($record/field[@element eq 'language'][1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'urn'][1]),
  local:calculate-score($record/field[@element eq 'identifier' and @qualifier eq 'uri'][1]),
  local:calculate-score($record/field[@element eq 'description' and @qualifier eq 'abstract'][1]),
  local:calculate-score($record/field[@element eq 'subject'][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'issued'][1]),
  local:calculate-score($record/field[@element eq 'publisher'][1]),
  local:calculate-score($record/field[@element eq 'format' and @qualifier eq 'extent'][1]),
  local:calculate-score($record/field[@element eq 'contributor' and not(@qualifier)][1]),
  local:calculate-score($record/field[@element eq 'date' and @qualifier eq 'available'][1]),
  local:calculate-score($record/field[@element eq 'rights'][1]),
  local:calculate-score($record/field[@element eq 'programme'][1]),
  local:calculate-score($record/file[1])
  )  
) div 18),2)}
</score>

</record>

}</scores>

let $csv :=
<csv>{
let $scores:= $thesis_scores union $diss_scores 

for $record in $scores/record
let $quality := $record/score 
let $id1 := $record/id1
let $id2 := $record/id2
let $ontaso := $record/ontaso
let $tallennus := substring-before($record/tallennuspvm,"-")

order by $quality ascending

return 

<record>
<score>{data($quality)}</score>
<id1>{data($id1)}</id1>
<id2>{data($id2)}</id2>
<ontaso>{data($ontaso)}</ontaso>
<tallennuspvm>{data($tallennus)}</tallennuspvm>
</record>

}</csv>

return $csv