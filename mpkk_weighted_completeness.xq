declare option output:method "csv";
declare option output:csv "header=yes, separator=|";

declare function local:calculate-score($element as element()?) as xs:decimal {
	 
		if (local-name($element) eq 'field' and $element/@element eq 'contributor' and $element/@qualifier eq 'author') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'title') then
			1
    else if (local-name($element) eq 'field' and $element/@element eq 'type' and $element/@qualifier eq 'okmtaso') then
			0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'language') then
			0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'issued') then
			0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'contributor' and not($element/@qualifier)) then
			0.5
    else if(local-name($element) eq 'field' and $element/@element eq 'date' and $element/@qualifier eq 'available') then
      0.5
		else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'urn') then
			0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'description') then
			1    
    else if (local-name($element) eq 'field' and $element/@element eq 'subject' and ($element/@qualifier eq 'ysa' or $element/@qualifier eq 'yso' or $element/@qualifier eq 'puho')) then
			1 
    else if (local-name($element) eq 'field' and $element/@element eq 'subject' and ($element/@qualifier eq 'tieteenala' or $element/@qualifier eq 'oppiaine')) then
      0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'rights') then
			0.5
    else if (local-name($element) eq 'field' and $element/@element eq 'publisher') then
			0.5 
    else if (local-name($element) eq 'field' and $element/@element eq 'format' and $element/@qualifier eq 'extent') then
			0.5 
    else if (local-name($element) eq 'file') then
			0.5  
    else if (local-name($element) eq 'field' and $element/@element eq 'identifier' and $element/@qualifier eq 'uri') then
			0.5                
  	else (0)
};

let $scores:=
<scores>{
  for $record in /records/Record/metadata/metadata
  
  return
  <record>
  <id>{data($record/field[@element eq 'identifier' and @qualifier eq 'uri']/@value)}</id>
  <ontaso>{data($record/field[@element eq 'type' and (@qualifier eq 'okmtaso')[1]]/@value)}</ontaso>
  <tallennuspvm>{data($record/field[@element eq 'date' and @qualifier eq 'accessioned'[1]]/@value)}</tallennuspvm>
  
  <score>{round-half-to-even((sum((
  local:calculate-score($record/*:field[@element eq 'contributor' and @qualifier eq 'author'][1]),
  local:calculate-score($record/*:field[@element eq 'title'][1]),
  local:calculate-score($record/*:field[@element eq 'type' and (@qualifier eq 'okmtaso')][1]),
  local:calculate-score($record/*:field[@element eq 'language'][1]),
  local:calculate-score($record/*:field[@element eq 'identifier' and @qualifier eq 'urn'][1]),
  local:calculate-score($record/*:field[@element eq 'identifier' and @qualifier eq 'uri'][1]),
  local:calculate-score($record/*:field[@element eq 'description'][1]),
  local:calculate-score($record/*:field[@element eq 'subject' and (@qualifier eq 'ysa'[1] or @qualifier eq 'yso'[1] or @qualifier eq 'puho'[1])][1]),
  local:calculate-score($record/*:field[@element eq 'subject' and (@qualifier eq 'tieteenala'[1] or @qualifier eq 'oppiaine'[1])][1]),
  local:calculate-score($record/*:field[@element eq 'date' and @qualifier eq 'issued'][1]),
  local:calculate-score($record/*:field[@element eq 'publisher'][1]),
  local:calculate-score($record/*:field[@element eq 'format' and @qualifier eq 'extent'][1]),
  local:calculate-score($record/*:field[@element eq 'contributor' and not(@qualifier)][1]),
  local:calculate-score($record/*:field[@element eq 'date' and @qualifier eq 'available'][1]),
  local:calculate-score($record/*:field[@element eq 'rights'][1]),
  local:calculate-score($record/*:file[1])
  )  
) div 11 ),2)}
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