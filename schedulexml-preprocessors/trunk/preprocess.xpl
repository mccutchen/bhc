<?xml version="1.0"?>
<p:pipeline version="1.0" xmlns:p="http://www.w3.org/ns/xproc">
    <p:xslt name="remove-locations">
        <p:input port="stylesheet">
            <p:document href="preprocessors/remove-locations.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="divisions-1">
        <p:input port="stylesheet">
            <p:document href="preprocessors/divisions-1.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="divisions-2">
        <p:input port="stylesheet">
            <p:document href="preprocessors/divisions-2.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="subjects-1">
        <p:input port="stylesheet">
            <p:document href="preprocessors/subjects-1.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="subjects-2">
        <p:input port="stylesheet">
            <p:document href="preprocessors/subjects-2.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="types-1">
        <p:input port="stylesheet">
            <p:document href="preprocessors/types-1.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="types-2">
        <p:input port="stylesheet">
            <p:document href="preprocessors/types-2.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="core">
        <p:input port="stylesheet">
            <p:document href="preprocessors/core.xsl"/>
        </p:input>
    </p:xslt>

    <p:xslt name="consolidate-descriptions">
        <p:input port="stylesheet">
            <p:document href="preprocessors/consolidate-descriptions.xsl"/>
        </p:input>
    </p:xslt>
</p:pipeline>

