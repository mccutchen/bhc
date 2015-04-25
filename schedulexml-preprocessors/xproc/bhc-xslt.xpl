<?xml version="1.0"?>

<!--
This creates a "simple" xslt step that can be used like so:

    <bhc:xslt stylesheet="remove-locations.xsl"/>
    <bhc:xslt stylesheet="divisions-1.xsl"/>

This is useful if you just need to apply one stylesheet after another in
sequence to an input document, and want to avoid repetitive code like:

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

Many thanks to Philip Fennell <Philip.Fennell@marklogic.com> and Romain
Deltour <rdeltour@gmail.com> on the xproc-dev mailing list:

http://lists.w3.org/Archives/Public/xproc-dev/2010Oct/0032.html
-->

<p:declare-step
    version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:bhc="http://www.brookhavencollege.edu/xml/xproc"
    type="bhc:xslt"
    name="xslt">

    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result" primary="true"/>

    <!-- What stylesheet are we applying in this step? -->
    <p:option name="stylesheet" required="true"/>

    <!-- This will load the specified stylesheet, which should be given as a
         path relative to ../preprocessors/ -->
    <p:load name="load-stylesheet">
        <p:with-option
            name="href"
            select="concat('../preprocessors/', $stylesheet)"/>
    </p:load>

    <!-- This will actually apply the specified stylesheet. -->
    <p:xslt>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load-stylesheet"/>
        </p:input>
        <p:input port="source">
            <p:pipe port="source" step="xslt"/>
        </p:input>
    </p:xslt>
</p:declare-step>
