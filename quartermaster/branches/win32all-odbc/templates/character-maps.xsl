<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:character-map name="unicode-xtags">
        <xsl:output-character character="&#160;" string="&lt;\#160&gt;"/>
        <xsl:output-character character="&#161;" string="&lt;\#161&gt;"/>
        <xsl:output-character character="&#162;" string="&lt;\#162&gt;"/>
        <xsl:output-character character="&#163;" string="&lt;\#163&gt;"/>
        <xsl:output-character character="&#164;" string="&lt;\#164&gt;"/>
        <xsl:output-character character="&#165;" string="&lt;\#165&gt;"/>
        <xsl:output-character character="&#166;" string="&lt;\#166&gt;"/>
        <xsl:output-character character="&#167;" string="&lt;\#167&gt;"/>
        <xsl:output-character character="&#168;" string="&lt;\#168&gt;"/>
        <xsl:output-character character="&#169;" string="&lt;\#169&gt;"/>
        <xsl:output-character character="&#170;" string="&lt;\#170&gt;"/>
        <xsl:output-character character="&#171;" string="&lt;\#171&gt;"/>
        <xsl:output-character character="&#172;" string="&lt;\#172&gt;"/>
        <xsl:output-character character="&#173;" string="&lt;\#173&gt;"/>
        <xsl:output-character character="&#174;" string="&lt;\#174&gt;"/>
        <xsl:output-character character="&#175;" string="&lt;\#175&gt;"/>
        <xsl:output-character character="&#176;" string="&lt;\#176&gt;"/>
        <xsl:output-character character="&#177;" string="&lt;\#177&gt;"/>
        <xsl:output-character character="&#178;" string="&lt;\#178&gt;"/>
        <xsl:output-character character="&#179;" string="&lt;\#179&gt;"/>
        <xsl:output-character character="&#180;" string="&lt;\#180&gt;"/>
        <xsl:output-character character="&#181;" string="&lt;\#181&gt;"/>
        <xsl:output-character character="&#182;" string="&lt;\#182&gt;"/>
        <xsl:output-character character="&#183;" string="&lt;\#183&gt;"/>
        <xsl:output-character character="&#184;" string="&lt;\#184&gt;"/>
        <xsl:output-character character="&#185;" string="&lt;\#185&gt;"/>
        <xsl:output-character character="&#186;" string="&lt;\#186&gt;"/>
        <xsl:output-character character="&#187;" string="&lt;\#187&gt;"/>
        <xsl:output-character character="&#188;" string="&lt;\#188&gt;"/>
        <xsl:output-character character="&#189;" string="&lt;\#189&gt;"/>
        <xsl:output-character character="&#190;" string="&lt;\#190&gt;"/>
        <xsl:output-character character="&#191;" string="&lt;\#191&gt;"/>
        <xsl:output-character character="&#192;" string="&lt;\#192&gt;"/>
        <xsl:output-character character="&#193;" string="&lt;\#193&gt;"/>
        <xsl:output-character character="&#194;" string="&lt;\#194&gt;"/>
        <xsl:output-character character="&#195;" string="&lt;\#195&gt;"/>
        <xsl:output-character character="&#196;" string="&lt;\#196&gt;"/>
        <xsl:output-character character="&#197;" string="&lt;\#197&gt;"/>
        <xsl:output-character character="&#198;" string="&lt;\#198&gt;"/>
        <xsl:output-character character="&#199;" string="&lt;\#199&gt;"/>
        <xsl:output-character character="&#200;" string="&lt;\#200&gt;"/>
        <xsl:output-character character="&#201;" string="&lt;\#201&gt;"/>
        <xsl:output-character character="&#202;" string="&lt;\#202&gt;"/>
        <xsl:output-character character="&#203;" string="&lt;\#203&gt;"/>
        <xsl:output-character character="&#204;" string="&lt;\#204&gt;"/>
        <xsl:output-character character="&#205;" string="&lt;\#205&gt;"/>
        <xsl:output-character character="&#206;" string="&lt;\#206&gt;"/>
        <xsl:output-character character="&#207;" string="&lt;\#207&gt;"/>
        <xsl:output-character character="&#208;" string="&lt;\#208&gt;"/>
        <xsl:output-character character="&#209;" string="&lt;\#209&gt;"/>
        <xsl:output-character character="&#210;" string="&lt;\#210&gt;"/>
        <xsl:output-character character="&#211;" string="&lt;\#211&gt;"/>
        <xsl:output-character character="&#212;" string="&lt;\#212&gt;"/>
        <xsl:output-character character="&#213;" string="&lt;\#213&gt;"/>
        <xsl:output-character character="&#214;" string="&lt;\#214&gt;"/>
        <xsl:output-character character="&#215;" string="&lt;\#215&gt;"/>
        <xsl:output-character character="&#216;" string="&lt;\#216&gt;"/>
        <xsl:output-character character="&#217;" string="&lt;\#217&gt;"/>
        <xsl:output-character character="&#218;" string="&lt;\#218&gt;"/>
        <xsl:output-character character="&#219;" string="&lt;\#219&gt;"/>
        <xsl:output-character character="&#220;" string="&lt;\#220&gt;"/>
        <xsl:output-character character="&#221;" string="&lt;\#221&gt;"/>
        <xsl:output-character character="&#222;" string="&lt;\#222&gt;"/>
        <xsl:output-character character="&#223;" string="&lt;\#223&gt;"/>
        <xsl:output-character character="&#224;" string="&lt;\#224&gt;"/>
        <xsl:output-character character="&#225;" string="&lt;\#225&gt;"/>
        <xsl:output-character character="&#226;" string="&lt;\#226&gt;"/>
        <xsl:output-character character="&#227;" string="&lt;\#227&gt;"/>
        <xsl:output-character character="&#228;" string="&lt;\#228&gt;"/>
        <xsl:output-character character="&#229;" string="&lt;\#229&gt;"/>
        <xsl:output-character character="&#230;" string="&lt;\#230&gt;"/>
        <xsl:output-character character="&#231;" string="&lt;\#231&gt;"/>
        <xsl:output-character character="&#232;" string="&lt;\#232&gt;"/>
        <xsl:output-character character="&#233;" string="&lt;\#233&gt;"/>
        <xsl:output-character character="&#234;" string="&lt;\#234&gt;"/>
        <xsl:output-character character="&#235;" string="&lt;\#235&gt;"/>
        <xsl:output-character character="&#236;" string="&lt;\#236&gt;"/>
        <xsl:output-character character="&#237;" string="&lt;\#237&gt;"/>
        <xsl:output-character character="&#238;" string="&lt;\#238&gt;"/>
        <xsl:output-character character="&#239;" string="&lt;\#239&gt;"/>
        <xsl:output-character character="&#240;" string="&lt;\#240&gt;"/>
        <xsl:output-character character="&#241;" string="&lt;\#241&gt;"/>
        <xsl:output-character character="&#242;" string="&lt;\#242&gt;"/>
        <xsl:output-character character="&#243;" string="&lt;\#243&gt;"/>
        <xsl:output-character character="&#244;" string="&lt;\#244&gt;"/>
        <xsl:output-character character="&#245;" string="&lt;\#245&gt;"/>
        <xsl:output-character character="&#246;" string="&lt;\#246&gt;"/>
        <xsl:output-character character="&#247;" string="&lt;\#247&gt;"/>
        <xsl:output-character character="&#249;" string="&lt;\#249&gt;"/>
        <xsl:output-character character="&#250;" string="&lt;\#250&gt;"/>
        <xsl:output-character character="&#251;" string="&lt;\#251&gt;"/>
        <xsl:output-character character="&#252;" string="&lt;\#252&gt;"/>
        <xsl:output-character character="&#253;" string="&lt;\#253&gt;"/>
        <xsl:output-character character="&#254;" string="&lt;\#254&gt;"/>
        <xsl:output-character character="&#255;" string="&lt;\#255&gt;"/>
        <xsl:output-character character="&#338;" string="&lt;\#338&gt;"/>
        <xsl:output-character character="&#339;" string="&lt;\#339&gt;"/>
        <xsl:output-character character="&#352;" string="&lt;\#352&gt;"/>
        <xsl:output-character character="&#353;" string="&lt;\#353&gt;"/>
        <xsl:output-character character="&#376;" string="&lt;\#376&gt;"/>
        <xsl:output-character character="&#402;" string="&lt;\#402&gt;"/>
        <xsl:output-character character="&#710;" string="&lt;\#710&gt;"/>
        <xsl:output-character character="&#732;" string="&lt;\#732&gt;"/>
        <xsl:output-character character="&#915;" string="&lt;\#915&gt;"/>
        <xsl:output-character character="&#916;" string="&lt;\#916&gt;"/>
        <xsl:output-character character="&#920;" string="&lt;\#920&gt;"/>
        <xsl:output-character character="&#923;" string="&lt;\#923&gt;"/>
        <xsl:output-character character="&#926;" string="&lt;\#926&gt;"/>
        <xsl:output-character character="&#928;" string="&lt;\#928&gt;"/>
        <xsl:output-character character="&#931;" string="&lt;\#931&gt;"/>
        <xsl:output-character character="&#933;" string="&lt;\#933&gt;"/>
        <xsl:output-character character="&#934;" string="&lt;\#934&gt;"/>
        <xsl:output-character character="&#936;" string="&lt;\#936&gt;"/>
        <xsl:output-character character="&#937;" string="&lt;\#937&gt;"/>
        <xsl:output-character character="&#945;" string="&lt;\#945&gt;"/>
        <xsl:output-character character="&#946;" string="&lt;\#946&gt;"/>
        <xsl:output-character character="&#947;" string="&lt;\#947&gt;"/>
        <xsl:output-character character="&#948;" string="&lt;\#948&gt;"/>
        <xsl:output-character character="&#949;" string="&lt;\#949&gt;"/>
        <xsl:output-character character="&#950;" string="&lt;\#950&gt;"/>
        <xsl:output-character character="&#951;" string="&lt;\#951&gt;"/>
        <xsl:output-character character="&#952;" string="&lt;\#952&gt;"/>
        <xsl:output-character character="&#953;" string="&lt;\#953&gt;"/>
        <xsl:output-character character="&#954;" string="&lt;\#954&gt;"/>
        <xsl:output-character character="&#955;" string="&lt;\#955&gt;"/>
        <xsl:output-character character="&#956;" string="&lt;\#956&gt;"/>
        <xsl:output-character character="&#957;" string="&lt;\#957&gt;"/>
        <xsl:output-character character="&#958;" string="&lt;\#958&gt;"/>
        <xsl:output-character character="&#959;" string="&lt;\#959&gt;"/>
        <xsl:output-character character="&#960;" string="&lt;\#960&gt;"/>
        <xsl:output-character character="&#961;" string="&lt;\#961&gt;"/>
        <xsl:output-character character="&#962;" string="&lt;\#962&gt;"/>
        <xsl:output-character character="&#963;" string="&lt;\#963&gt;"/>
        <xsl:output-character character="&#964;" string="&lt;\#964&gt;"/>
        <xsl:output-character character="&#965;" string="&lt;\#965&gt;"/>
        <xsl:output-character character="&#966;" string="&lt;\#966&gt;"/>
        <xsl:output-character character="&#967;" string="&lt;\#967&gt;"/>
        <xsl:output-character character="&#968;" string="&lt;\#968&gt;"/>
        <xsl:output-character character="&#969;" string="&lt;\#969&gt;"/>
        <xsl:output-character character="&#977;" string="&lt;\#977&gt;"/>
        <xsl:output-character character="&#978;" string="&lt;\#978&gt;"/>
        <xsl:output-character character="&#982;" string="&lt;\#982&gt;"/>
        <xsl:output-character character="&#8194;" string="&lt;\#8194&gt;"/>
        <xsl:output-character character="&#8195;" string="&lt;\#8195&gt;"/>
        <xsl:output-character character="&#8201;" string="&lt;\#8201&gt;"/>
        <xsl:output-character character="&#8204;" string="&lt;\#8204&gt;"/>
        <xsl:output-character character="&#8205;" string="&lt;\#8205&gt;"/>
        <xsl:output-character character="&#8206;" string="&lt;\#8206&gt;"/>
        <xsl:output-character character="&#8207;" string="&lt;\#8207&gt;"/>
        <xsl:output-character character="&#8211;" string="&lt;\#8211&gt;"/>
        <xsl:output-character character="&#8212;" string="&lt;\#8212&gt;"/>
        <xsl:output-character character="&#8216;" string="'"/>
        <xsl:output-character character="&#8217;" string="'"/>
        <xsl:output-character character="&#8218;" string="&lt;\#8218&gt;"/>
        <xsl:output-character character="&#8220;" string="&quot;"/>
        <xsl:output-character character="&#8221;" string="&quot;"/>
        <xsl:output-character character="&#8222;" string="&lt;\#8222&gt;"/>
        <xsl:output-character character="&#8224;" string="&lt;\#8224&gt;"/>
        <xsl:output-character character="&#8225;" string="&lt;\#8225&gt;"/>
        <xsl:output-character character="&#8226;" string="&lt;\#8226&gt;"/>
        <xsl:output-character character="&#8230;" string="&lt;\#8230&gt;"/>
        <xsl:output-character character="&#8240;" string="&lt;\#8240&gt;"/>
        <xsl:output-character character="&#8242;" string="&lt;\#8242&gt;"/>
        <xsl:output-character character="&#8243;" string="&lt;\#8243&gt;"/>
        <xsl:output-character character="&#8249;" string="&lt;\#8249&gt;"/>
        <xsl:output-character character="&#8250;" string="&lt;\#8250&gt;"/>
        <xsl:output-character character="&#8254;" string="&lt;\#8254&gt;"/>
        <xsl:output-character character="&#8260;" string="&lt;\#8260&gt;"/>
        <xsl:output-character character="&#8364;" string="&lt;\#8364&gt;"/>
        <xsl:output-character character="&#8465;" string="&lt;\#8465&gt;"/>
        <xsl:output-character character="&#8472;" string="&lt;\#8472&gt;"/>
        <xsl:output-character character="&#8476;" string="&lt;\#8476&gt;"/>
        <xsl:output-character character="&#8482;" string="&lt;\#8482&gt;"/>
        <xsl:output-character character="&#8501;" string="&lt;\#8501&gt;"/>
        <xsl:output-character character="&#8592;" string="&lt;\#8592&gt;"/>
        <xsl:output-character character="&#8594;" string="&lt;\#8594&gt;"/>
        <xsl:output-character character="&#8595;" string="&lt;\#8595&gt;"/>
        <xsl:output-character character="&#8596;" string="&lt;\#8596&gt;"/>
        <xsl:output-character character="&#8629;" string="&lt;\#8629&gt;"/>
        <xsl:output-character character="&#8656;" string="&lt;\#8656&gt;"/>
        <xsl:output-character character="&#8657;" string="&lt;\#8657&gt;"/>
        <xsl:output-character character="&#8658;" string="&lt;\#8658&gt;"/>
        <xsl:output-character character="&#8659;" string="&lt;\#8659&gt;"/>
        <xsl:output-character character="&#8660;" string="&lt;\#8660&gt;"/>
        <xsl:output-character character="&#8704;" string="&lt;\#8704&gt;"/>
        <xsl:output-character character="&#8706;" string="&lt;\#8706&gt;"/>
        <xsl:output-character character="&#8707;" string="&lt;\#8707&gt;"/>
        <xsl:output-character character="&#8709;" string="&lt;\#8709&gt;"/>
        <xsl:output-character character="&#8711;" string="&lt;\#8711&gt;"/>
        <xsl:output-character character="&#8712;" string="&lt;\#8712&gt;"/>
        <xsl:output-character character="&#8713;" string="&lt;\#8713&gt;"/>
        <xsl:output-character character="&#8715;" string="&lt;\#8715&gt;"/>
        <xsl:output-character character="&#8719;" string="&lt;\#8719&gt;"/>
        <xsl:output-character character="&#8721;" string="&lt;\#8721&gt;"/>
        <xsl:output-character character="&#8722;" string="&lt;\#8722&gt;"/>
        <xsl:output-character character="&#8727;" string="&lt;\#8727&gt;"/>
        <xsl:output-character character="&#8730;" string="&lt;\#8730&gt;"/>
        <xsl:output-character character="&#8733;" string="&lt;\#8733&gt;"/>
        <xsl:output-character character="&#8734;" string="&lt;\#8734&gt;"/>
        <xsl:output-character character="&#8736;" string="&lt;\#8736&gt;"/>
        <xsl:output-character character="&#8743;" string="&lt;\#8743&gt;"/>
        <xsl:output-character character="&#8744;" string="&lt;\#8744&gt;"/>
        <xsl:output-character character="&#8745;" string="&lt;\#8745&gt;"/>
        <xsl:output-character character="&#8746;" string="&lt;\#8746&gt;"/>
        <xsl:output-character character="&#8747;" string="&lt;\#8747&gt;"/>
        <xsl:output-character character="&#8756;" string="&lt;\#8756&gt;"/>
        <xsl:output-character character="&#8764;" string="&lt;\#8764&gt;"/>
        <xsl:output-character character="&#8773;" string="&lt;\#8773&gt;"/>
        <xsl:output-character character="&#8776;" string="&lt;\#8776&gt;"/>
        <xsl:output-character character="&#8800;" string="&lt;\#8800&gt;"/>
        <xsl:output-character character="&#8801;" string="&lt;\#8801&gt;"/>
        <xsl:output-character character="&#8804;" string="&lt;\#8804&gt;"/>
        <xsl:output-character character="&#8805;" string="&lt;\#8805&gt;"/>
        <xsl:output-character character="&#8834;" string="&lt;\#8834&gt;"/>
        <xsl:output-character character="&#8835;" string="&lt;\#8835&gt;"/>
        <xsl:output-character character="&#8836;" string="&lt;\#8836&gt;"/>
        <xsl:output-character character="&#8838;" string="&lt;\#8838&gt;"/>
        <xsl:output-character character="&#8839;" string="&lt;\#8839&gt;"/>
        <xsl:output-character character="&#8853;" string="&lt;\#8853&gt;"/>
        <xsl:output-character character="&#8855;" string="&lt;\#8855&gt;"/>
        <xsl:output-character character="&#8869;" string="&lt;\#8869&gt;"/>
        <xsl:output-character character="&#8901;" string="&lt;\#8901&gt;"/>
        <xsl:output-character character="&#8968;" string="&lt;\#8968&gt;"/>
        <xsl:output-character character="&#8969;" string="&lt;\#8969&gt;"/>
        <xsl:output-character character="&#8970;" string="&lt;\#8970&gt;"/>
        <xsl:output-character character="&#8971;" string="&lt;\#8971&gt;"/>
        <xsl:output-character character="&#9001;" string="&lt;\#9001&gt;"/>
        <xsl:output-character character="&#9002;" string="&lt;\#9002&gt;"/>
        <xsl:output-character character="&#9674;" string="&lt;\#9674&gt;"/>
        <xsl:output-character character="&#9824;" string="&lt;\#9824&gt;"/>
        <xsl:output-character character="&#9827;" string="&lt;\#9827&gt;"/>
        <xsl:output-character character="&#9829;" string="&lt;\#9829&gt;"/>
        <xsl:output-character character="&#9830;" string="&lt;\#9830&gt;"/>
    </xsl:character-map>
    
    <xsl:character-map name="macroman-xtags">
        <xsl:output-character character="&#x00C4;" string="&lt;\#128&gt;" /> 
        <xsl:output-character character="&#x00C5;" string="&lt;\#129&gt;" /> 
        <xsl:output-character character="&#x00C7;" string="&lt;\#130&gt;" /> 
        <xsl:output-character character="&#x00C9;" string="&lt;\#131&gt;" /> 
        <xsl:output-character character="&#x00D1;" string="&lt;\#132&gt;" /> 
        <xsl:output-character character="&#x00D6;" string="&lt;\#133&gt;" /> 
        <xsl:output-character character="&#x00DC;" string="&lt;\#134&gt;" /> 
        <xsl:output-character character="&#x00E1;" string="&lt;\#135&gt;" /> 
        <xsl:output-character character="&#x00E0;" string="&lt;\#136&gt;" /> 
        <xsl:output-character character="&#x00E2;" string="&lt;\#137&gt;" /> 
        <xsl:output-character character="&#x00E4;" string="&lt;\#138&gt;" /> 
        <xsl:output-character character="&#x00E3;" string="&lt;\#139&gt;" /> 
        <xsl:output-character character="&#x00E5;" string="&lt;\#140&gt;" /> 
        <xsl:output-character character="&#x00E7;" string="&lt;\#141&gt;" /> 
        <xsl:output-character character="&#x00E9;" string="&lt;\#142&gt;" /> 
        <xsl:output-character character="&#x00E8;" string="&lt;\#143&gt;" /> 
        <xsl:output-character character="&#x00EA;" string="&lt;\#144&gt;" /> 
        <xsl:output-character character="&#x00EB;" string="&lt;\#145&gt;" /> 
        <xsl:output-character character="&#x00ED;" string="&lt;\#146&gt;" /> 
        <xsl:output-character character="&#x00EC;" string="&lt;\#147&gt;" /> 
        <xsl:output-character character="&#x00EE;" string="&lt;\#148&gt;" /> 
        <xsl:output-character character="&#x00EF;" string="&lt;\#149&gt;" /> 
        <xsl:output-character character="&#x00F1;" string="&lt;\#150&gt;" /> 
        <xsl:output-character character="&#x00F3;" string="&lt;\#151&gt;" /> 
        <xsl:output-character character="&#x00F2;" string="&lt;\#152&gt;" /> 
        <xsl:output-character character="&#x00F4;" string="&lt;\#153&gt;" /> 
        <xsl:output-character character="&#x00F6;" string="&lt;\#154&gt;" /> 
        <xsl:output-character character="&#x00F5;" string="&lt;\#155&gt;" /> 
        <xsl:output-character character="&#x00FA;" string="&lt;\#156&gt;" /> 
        <xsl:output-character character="&#x00F9;" string="&lt;\#157&gt;" /> 
        <xsl:output-character character="&#x00FB;" string="&lt;\#158&gt;" /> 
        <xsl:output-character character="&#x00FC;" string="&lt;\#159&gt;" /> 
        <xsl:output-character character="&#x2020;" string="&lt;\#160&gt;" /> 
        <xsl:output-character character="&#x00B0;" string="&lt;\#161&gt;" /> 
        <xsl:output-character character="&#x00A2;" string="&lt;\#162&gt;" /> 
        <xsl:output-character character="&#x00A3;" string="&lt;\#163&gt;" /> 
        <xsl:output-character character="&#x00A7;" string="&lt;\#164&gt;" /> 
        <xsl:output-character character="&#x2022;" string="&lt;\#165&gt;" /> 
        <xsl:output-character character="&#x00B6;" string="&lt;\#166&gt;" /> 
        <xsl:output-character character="&#x00DF;" string="&lt;\#167&gt;" /> 
        <xsl:output-character character="&#x00AE;" string="&lt;\#168&gt;" /> 
        <xsl:output-character character="&#x00A9;" string="&lt;\#169&gt;" /> 
        <xsl:output-character character="&#x2122;" string="&lt;\#170&gt;" /> 
        <xsl:output-character character="&#x00B4;" string="&lt;\#171&gt;" /> 
        <xsl:output-character character="&#x00A8;" string="&lt;\#172&gt;" /> 
        <xsl:output-character character="&#x2260;" string="&lt;\#173&gt;" /> 
        <xsl:output-character character="&#x00C6;" string="&lt;\#174&gt;" /> 
        <xsl:output-character character="&#x00D8;" string="&lt;\#175&gt;" /> 
        <xsl:output-character character="&#x221E;" string="&lt;\#176&gt;" /> 
        <xsl:output-character character="&#x00B1;" string="&lt;\#177&gt;" /> <!-- plus-minus sign -->
        <xsl:output-character character="&#x2264;" string="&lt;\#178&gt;" /> <!-- less-than or equal to -->
        <xsl:output-character character="&#x2265;" string="&lt;\#179&gt;" /> <!-- greater-than or equal to -->
        <xsl:output-character character="&#x00A5;" string="&lt;\#180&gt;" /> 
        <xsl:output-character character="&#x00B5;" string="&lt;\#181&gt;" /> 
        <xsl:output-character character="&#x2202;" string="&lt;\#182&gt;" /> 
        <xsl:output-character character="&#x2211;" string="&lt;\#183&gt;" /> <!-- n-ary summation -->
        <xsl:output-character character="&#x220F;" string="&lt;\#184&gt;" /> <!-- n-ary product -->
        <xsl:output-character character="&#x03C0;" string="&lt;\#185&gt;" /> 
        <xsl:output-character character="&#x222B;" string="&lt;\#186&gt;" /> 
        <xsl:output-character character="&#x00AA;" string="&lt;\#187&gt;" /> 
        <xsl:output-character character="&#x00BA;" string="&lt;\#188&gt;" /> 
        <xsl:output-character character="&#x03A9;" string="&lt;\#189&gt;" /> 
        <xsl:output-character character="&#x00E6;" string="&lt;\#190&gt;" /> 
        <xsl:output-character character="&#x00F8;" string="&lt;\#191&gt;" /> 
        <xsl:output-character character="&#x00BF;" string="&lt;\#192&gt;" /> 
        <xsl:output-character character="&#x00A1;" string="&lt;\#193&gt;" /> 
        <xsl:output-character character="&#x00AC;" string="&lt;\#194&gt;" /> 
        <xsl:output-character character="&#x221A;" string="&lt;\#195&gt;" /> 
        <xsl:output-character character="&#x0192;" string="&lt;\#196&gt;" /> 
        <xsl:output-character character="&#x2248;" string="&lt;\#197&gt;" /> 
        <xsl:output-character character="&#x2206;" string="&lt;\#198&gt;" /> 
        <xsl:output-character character="&#x00AB;" string="&lt;\#199&gt;" /> <!-- left-pointing double angle quotation mark -->
        <xsl:output-character character="&#x00BB;" string="&lt;\#200&gt;" /> <!-- right-pointing double angle quotation mark -->
        <xsl:output-character character="&#x2026;" string="&lt;\#201&gt;" /> 
        <xsl:output-character character="&#x00A0;" string="&lt;\#202&gt;" /> <!-- no-break space -->
        <xsl:output-character character="&#x00C0;" string="&lt;\#203&gt;" /> 
        <xsl:output-character character="&#x00C3;" string="&lt;\#204&gt;" /> 
        <xsl:output-character character="&#x00D5;" string="&lt;\#205&gt;" /> 
        <xsl:output-character character="&#x0152;" string="&lt;\#206&gt;" /> 
        <xsl:output-character character="&#x0153;" string="&lt;\#207&gt;" /> 
        <xsl:output-character character="&#x2013;" string="&lt;\#208&gt;" /> 
        <xsl:output-character character="&#x2014;" string="&lt;\#209&gt;" /> 
        <xsl:output-character character="&#x201C;" string="&lt;\#210&gt;" /> 
        <xsl:output-character character="&#x201D;" string="&lt;\#211&gt;" /> 
        <xsl:output-character character="&#x2018;" string="&lt;\#212&gt;" /> 
        <xsl:output-character character="&#x2019;" string="&lt;\#213&gt;" /> 
        <xsl:output-character character="&#x00F7;" string="&lt;\#214&gt;" /> 
        <xsl:output-character character="&#x25CA;" string="&lt;\#215&gt;" /> 
        <xsl:output-character character="&#x00FF;" string="&lt;\#216&gt;" /> 
        <xsl:output-character character="&#x0178;" string="&lt;\#217&gt;" /> 
        <xsl:output-character character="&#x2044;" string="&lt;\#218&gt;" /> 
        <xsl:output-character character="&#x20AC;" string="&lt;\#219&gt;" /> 
        <xsl:output-character character="&#x2039;" string="&lt;\#220&gt;" /> 
        <xsl:output-character character="&#x203A;" string="&lt;\#221&gt;" /> 
        <xsl:output-character character="&#xFB01;" string="&lt;\#222&gt;" /> 
        <xsl:output-character character="&#xFB02;" string="&lt;\#223&gt;" /> 
        <xsl:output-character character="&#x2021;" string="&lt;\#224&gt;" /> 
        <xsl:output-character character="&#x00B7;" string="&lt;\#225&gt;" /> 
        <xsl:output-character character="&#x201A;" string="&lt;\#226&gt;" /> 
        <xsl:output-character character="&#x201E;" string="&lt;\#227&gt;" /> 
        <xsl:output-character character="&#x2030;" string="&lt;\#228&gt;" /> 
        <xsl:output-character character="&#x00C2;" string="&lt;\#229&gt;" /> 
        <xsl:output-character character="&#x00CA;" string="&lt;\#230&gt;" /> 
        <xsl:output-character character="&#x00C1;" string="&lt;\#231&gt;" /> 
        <xsl:output-character character="&#x00CB;" string="&lt;\#232&gt;" /> 
        <xsl:output-character character="&#x00C8;" string="&lt;\#233&gt;" /> 
        <xsl:output-character character="&#x00CD;" string="&lt;\#234&gt;" /> 
        <xsl:output-character character="&#x00CE;" string="&lt;\#235&gt;" /> 
        <xsl:output-character character="&#x00CF;" string="&lt;\#236&gt;" /> 
        <xsl:output-character character="&#x00CC;" string="&lt;\#237&gt;" /> 
        <xsl:output-character character="&#x00D3;" string="&lt;\#238&gt;" /> 
        <xsl:output-character character="&#x00D4;" string="&lt;\#239&gt;" /> 
        <xsl:output-character character="&#xF8FF;" string="&lt;\#240&gt;" /> 
        <xsl:output-character character="&#x00D2;" string="&lt;\#241&gt;" /> 
        <xsl:output-character character="&#x00DA;" string="&lt;\#242&gt;" /> 
        <xsl:output-character character="&#x00DB;" string="&lt;\#243&gt;" /> 
        <xsl:output-character character="&#x00D9;" string="&lt;\#244&gt;" /> 
        <xsl:output-character character="&#x0131;" string="&lt;\#245&gt;" /> 
        <xsl:output-character character="&#x02C6;" string="&lt;\#246&gt;" /> 
        <xsl:output-character character="&#x02DC;" string="&lt;\#247&gt;" /> 
        <xsl:output-character character="&#x00AF;" string="&lt;\#248&gt;" /> 
        <xsl:output-character character="&#x02D8;" string="&lt;\#249&gt;" /> 
        <xsl:output-character character="&#x02D9;" string="&lt;\#250&gt;" /> 
        <xsl:output-character character="&#x02DA;" string="&lt;\#251&gt;" /> 
        <xsl:output-character character="&#x00B8;" string="&lt;\#252&gt;" /> 
        <xsl:output-character character="&#x02DD;" string="&lt;\#253&gt;" /> 
        <xsl:output-character character="&#x02DB;" string="&lt;\#254&gt;" /> 
        <xsl:output-character character="&#x02C7;" string="&lt;\#255&gt;" /> 
    </xsl:character-map>
    
    
    <xsl:character-map name="iso-xtags">
        <!-- this maps unicode characters to their iso-8859-1 Quark XPress Xtags counterparts -->
        <xsl:output-character character="&#x0080;" string="&lt;\#128&gt;" /> 
        <xsl:output-character character="&#x0081;" string="&lt;\#129&gt;" /> 
        <xsl:output-character character="&#x0082;" string="&lt;\#130&gt;" /> 
        <xsl:output-character character="&#x0083;" string="&lt;\#131&gt;" /> 
        <xsl:output-character character="&#x0084;" string="&lt;\#132&gt;" /> 
        <xsl:output-character character="&#x0085;" string="&lt;\#133&gt;" /> 
        <xsl:output-character character="&#x0086;" string="&lt;\#134&gt;" /> 
        <xsl:output-character character="&#x0087;" string="&lt;\#135&gt;" /> 
        <xsl:output-character character="&#x0088;" string="&lt;\#136&gt;" /> 
        <xsl:output-character character="&#x0089;" string="&lt;\#137&gt;" /> 
        <xsl:output-character character="&#x008A;" string="&lt;\#138&gt;" /> 
        <xsl:output-character character="&#x008B;" string="&lt;\#139&gt;" /> 
        <xsl:output-character character="&#x008C;" string="&lt;\#140&gt;" /> 
        <xsl:output-character character="&#x008D;" string="&lt;\#141&gt;" /> 
        <xsl:output-character character="&#x008E;" string="&lt;\#142&gt;" /> 
        <xsl:output-character character="&#x008F;" string="&lt;\#143&gt;" /> 
        <xsl:output-character character="&#x0090;" string="&lt;\#144&gt;" /> 
        <xsl:output-character character="&#x0091;" string="&lt;\#145&gt;" /> 
        <xsl:output-character character="&#x0092;" string="&lt;\#146&gt;" /> 
        <xsl:output-character character="&#x0093;" string="&lt;\#147&gt;" /> 
        <xsl:output-character character="&#x0094;" string="&lt;\#148&gt;" /> 
        <xsl:output-character character="&#x0095;" string="&lt;\#149&gt;" /> 
        <xsl:output-character character="&#x0096;" string="&lt;\#150&gt;" /> 
        <xsl:output-character character="&#x0097;" string="&lt;\#151&gt;" /> 
        <xsl:output-character character="&#x0098;" string="&lt;\#152&gt;" /> 
        <xsl:output-character character="&#x0099;" string="&lt;\#153&gt;" /> 
        <xsl:output-character character="&#x009A;" string="&lt;\#154&gt;" /> 
        <xsl:output-character character="&#x009B;" string="&lt;\#155&gt;" /> 
        <xsl:output-character character="&#x009C;" string="&lt;\#156&gt;" /> 
        <xsl:output-character character="&#x009D;" string="&lt;\#157&gt;" /> 
        <xsl:output-character character="&#x009E;" string="&lt;\#158&gt;" /> 
        <xsl:output-character character="&#x009F;" string="&lt;\#159&gt;" /> 
        <xsl:output-character character="&#x00A0;" string="&lt;\#160&gt;" /> <!-- NO-BREAK SPACE -->
        <xsl:output-character character="&#x00A1;" string="&lt;\#161&gt;" /> 
        <xsl:output-character character="&#x00A2;" string="&lt;\#162&gt;" /> 
        <xsl:output-character character="&#x00A3;" string="&lt;\#163&gt;" /> 
        <xsl:output-character character="&#x00A4;" string="&lt;\#164&gt;" /> 
        <xsl:output-character character="&#x00A5;" string="&lt;\#165&gt;" /> 
        <xsl:output-character character="&#x00A6;" string="&lt;\#166&gt;" /> 
        <xsl:output-character character="&#x00A7;" string="&lt;\#167&gt;" /> 
        <xsl:output-character character="&#x00A8;" string="&lt;\#168&gt;" /> 
        <xsl:output-character character="&#x00A9;" string="&lt;\#169&gt;" /> 
        <xsl:output-character character="&#x00AA;" string="&lt;\#170&gt;" /> 
        <xsl:output-character character="&#x00AB;" string="&lt;\#171&gt;" /> <!-- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK -->
        <xsl:output-character character="&#x00AC;" string="&lt;\#172&gt;" /> 
        <xsl:output-character character="&#x00AD;" string="&lt;\#173&gt;" /> 
        <xsl:output-character character="&#x00AE;" string="&lt;\#174&gt;" /> 
        <xsl:output-character character="&#x00AF;" string="&lt;\#175&gt;" /> 
        <xsl:output-character character="&#x00B0;" string="&lt;\#176&gt;" /> 
        <xsl:output-character character="&#x00B1;" string="&lt;\#177&gt;" /> <!-- PLUS-MINUS SIGN -->
        <xsl:output-character character="&#x00B2;" string="&lt;\#178&gt;" /> 
        <xsl:output-character character="&#x00B3;" string="&lt;\#179&gt;" /> 
        <xsl:output-character character="&#x00B4;" string="&lt;\#180&gt;" /> 
        <xsl:output-character character="&#x00B5;" string="&lt;\#181&gt;" /> 
        <xsl:output-character character="&#x00B6;" string="&lt;\#182&gt;" /> 
        <xsl:output-character character="&#x00B7;" string="&lt;\#183&gt;" /> 
        <xsl:output-character character="&#x00B8;" string="&lt;\#184&gt;" /> 
        <xsl:output-character character="&#x00B9;" string="&lt;\#185&gt;" /> 
        <xsl:output-character character="&#x00BA;" string="&lt;\#186&gt;" /> 
        <xsl:output-character character="&#x00BB;" string="&lt;\#187&gt;" /> <!-- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK -->
        <xsl:output-character character="&#x00BC;" string="&lt;\#188&gt;" /> 
        <xsl:output-character character="&#x00BD;" string="&lt;\#189&gt;" /> 
        <xsl:output-character character="&#x00BE;" string="&lt;\#190&gt;" /> 
        <xsl:output-character character="&#x00BF;" string="&lt;\#191&gt;" /> 
        <xsl:output-character character="&#x00C0;" string="&lt;\#192&gt;" /> 
        <xsl:output-character character="&#x00C1;" string="&lt;\#193&gt;" /> 
        <xsl:output-character character="&#x00C2;" string="&lt;\#194&gt;" /> 
        <xsl:output-character character="&#x00C3;" string="&lt;\#195&gt;" /> 
        <xsl:output-character character="&#x00C4;" string="&lt;\#196&gt;" /> 
        <xsl:output-character character="&#x00C5;" string="&lt;\#197&gt;" /> 
        <xsl:output-character character="&#x00C6;" string="&lt;\#198&gt;" /> 
        <xsl:output-character character="&#x00C7;" string="&lt;\#199&gt;" /> 
        <xsl:output-character character="&#x00C8;" string="&lt;\#200&gt;" /> 
        <xsl:output-character character="&#x00C9;" string="&lt;\#201&gt;" /> 
        <xsl:output-character character="&#x00CA;" string="&lt;\#202&gt;" /> 
        <xsl:output-character character="&#x00CB;" string="&lt;\#203&gt;" /> 
        <xsl:output-character character="&#x00CC;" string="&lt;\#204&gt;" /> 
        <xsl:output-character character="&#x00CD;" string="&lt;\#205&gt;" /> 
        <xsl:output-character character="&#x00CE;" string="&lt;\#206&gt;" /> 
        <xsl:output-character character="&#x00CF;" string="&lt;\#207&gt;" /> 
        <xsl:output-character character="&#x00D0;" string="&lt;\#208&gt;" /> <!-- LATIN CAPITAL LETTER ETH (Icelandic) -->
        <xsl:output-character character="&#x00D1;" string="&lt;\#209&gt;" /> 
        <xsl:output-character character="&#x00D2;" string="&lt;\#210&gt;" /> 
        <xsl:output-character character="&#x00D3;" string="&lt;\#211&gt;" /> 
        <xsl:output-character character="&#x00D4;" string="&lt;\#212&gt;" /> 
        <xsl:output-character character="&#x00D5;" string="&lt;\#213&gt;" /> 
        <xsl:output-character character="&#x00D6;" string="&lt;\#214&gt;" /> 
        <xsl:output-character character="&#x00D7;" string="&lt;\#215&gt;" /> 
        <xsl:output-character character="&#x00D8;" string="&lt;\#216&gt;" /> 
        <xsl:output-character character="&#x00D9;" string="&lt;\#217&gt;" /> 
        <xsl:output-character character="&#x00DA;" string="&lt;\#218&gt;" /> 
        <xsl:output-character character="&#x00DB;" string="&lt;\#219&gt;" /> 
        <xsl:output-character character="&#x00DC;" string="&lt;\#220&gt;" /> 
        <xsl:output-character character="&#x00DD;" string="&lt;\#221&gt;" /> 
        <xsl:output-character character="&#x00DE;" string="&lt;\#222&gt;" /> <!-- LATIN CAPITAL LETTER THORN (Icelandic) -->
        <xsl:output-character character="&#x00DF;" string="&lt;\#223&gt;" /> <!-- LATIN SMALL LETTER SHARP S (German) -->
        <xsl:output-character character="&#x00E0;" string="&lt;\#224&gt;" /> 
        <xsl:output-character character="&#x00E1;" string="&lt;\#225&gt;" /> 
        <xsl:output-character character="&#x00E2;" string="&lt;\#226&gt;" /> 
        <xsl:output-character character="&#x00E3;" string="&lt;\#227&gt;" /> 
        <xsl:output-character character="&#x00E4;" string="&lt;\#228&gt;" /> 
        <xsl:output-character character="&#x00E5;" string="&lt;\#229&gt;" /> 
        <xsl:output-character character="&#x00E6;" string="&lt;\#230&gt;" /> 
        <xsl:output-character character="&#x00E7;" string="&lt;\#231&gt;" /> 
        <xsl:output-character character="&#x00E8;" string="&lt;\#232&gt;" /> 
        <xsl:output-character character="&#x00E9;" string="&lt;\#233&gt;" /> 
        <xsl:output-character character="&#x00EA;" string="&lt;\#234&gt;" /> 
        <xsl:output-character character="&#x00EB;" string="&lt;\#235&gt;" /> 
        <xsl:output-character character="&#x00EC;" string="&lt;\#236&gt;" /> 
        <xsl:output-character character="&#x00ED;" string="&lt;\#237&gt;" /> 
        <xsl:output-character character="&#x00EE;" string="&lt;\#238&gt;" /> 
        <xsl:output-character character="&#x00EF;" string="&lt;\#239&gt;" /> 
        <xsl:output-character character="&#x00F0;" string="&lt;\#240&gt;" /> <!-- LATIN SMALL LETTER ETH (Icelandic) -->
        <xsl:output-character character="&#x00F1;" string="&lt;\#241&gt;" /> 
        <xsl:output-character character="&#x00F2;" string="&lt;\#242&gt;" /> 
        <xsl:output-character character="&#x00F3;" string="&lt;\#243&gt;" /> 
        <xsl:output-character character="&#x00F4;" string="&lt;\#244&gt;" /> 
        <xsl:output-character character="&#x00F5;" string="&lt;\#245&gt;" /> 
        <xsl:output-character character="&#x00F6;" string="&lt;\#246&gt;" /> 
        <xsl:output-character character="&#x00F7;" string="&lt;\#247&gt;" /> 
        <xsl:output-character character="&#x00F8;" string="&lt;\#248&gt;" /> 
        <xsl:output-character character="&#x00F9;" string="&lt;\#249&gt;" /> 
        <xsl:output-character character="&#x00FA;" string="&lt;\#250&gt;" /> 
        <xsl:output-character character="&#x00FB;" string="&lt;\#251&gt;" /> 
        <xsl:output-character character="&#x00FC;" string="&lt;\#252&gt;" /> 
        <xsl:output-character character="&#x00FD;" string="&lt;\#253&gt;" /> 
        <xsl:output-character character="&#x00FE;" string="&lt;\#254&gt;" /> <!-- LATIN SMALL LETTER THORN (Icelandic) -->
        <xsl:output-character character="&#x00FF;" string="&lt;\#255&gt;" /> 
    </xsl:character-map>
</xsl:stylesheet>