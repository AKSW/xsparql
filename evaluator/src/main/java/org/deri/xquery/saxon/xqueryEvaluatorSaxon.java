/**
 *
 * Copyright (C) 2011, NUI Galway.
 * All rights reserved.
 *
 * The software in this package is published under the terms of the BSD style license a copy of which has been included
 * with this distribution in the bsb_license.txt file and/or available on NUI Galway Server at
 * http://www.deri.ie/publications/tools/bsd_license.txt
 *
 * Created: 09 February 2011, Reasoning and Querying Unit (URQ), Digital Enterprise Research Institute (DERI) on behalf of
 * NUI Galway.
 */
package org.deri.xquery.saxon;

import java.io.*;
import java.util.HashMap;
import java.util.Map;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XQueryCompiler;

import org.deri.xquery.XQueryEvaluator;
import org.deri.xsparql.rewriter.XSPARQLProcessor;

/**
 * Evaluate an XQuery using the Saxon API
 * 
 * 
 * Created: Tue Sep 28 14:54:49 2010
 * 
 * @author <a href="mailto:nuno [dot] lopes [at] deri [dot] org">Nuno Lopes</a>
 * @version 1.0
 */
public class xqueryEvaluatorSaxon implements XQueryEvaluator {

  private Processor proc;

  private XQueryCompiler xqueryComp;

  private Serializer serializer;

  private boolean licensedVersion;

  private boolean omitXMLDecl = true;

  /**
   * use validating XQuery engine
   */
  public boolean validatingXQuery = true;

  public void setValidatingXQuery(boolean validatingXQuery) {
    this.validatingXQuery = validatingXQuery;
  }

  /**
   * external variables for Xquery evaluation TODO refactor
   */
  public Map<String, String> xqueryExternalVars = new HashMap<String, String>();

  public void setExternalVariables(Map<String, String> xqueryExternalVars) {
    this.xqueryExternalVars = xqueryExternalVars;

  }

  /**
   * Creates a new <code>XQueryEvaluatorSaxon</code> instance.
   * 
   */
  public xqueryEvaluatorSaxon(boolean licensedVersion) {

    this.licensedVersion = licensedVersion;

    proc = new Processor(licensedVersion);

    proc.registerExtensionFunction(new sparqlQueryExtFunction());
    proc.registerExtensionFunction(new turtleGraphToURIExtFunction());
    proc.registerExtensionFunction(new doPostQueryExtFunction());
    proc.registerExtensionFunction(new createScopedDatasetExtFunction());
    proc.registerExtensionFunction(new sparqlScopedDatasetExtFunction());
    proc.registerExtensionFunction(new deleteScopedDatasetExtFunction());
    proc.registerExtensionFunction(new scopedDatasetPopResultsExtFunction());

    // debug external functions
    // proc.setConfigurationProperty(FeatureKeys.TRACE_EXTERNAL_FUNCTIONS,
    // true);

    initializeSerializer();

  }

  /**
   * returns the XQuery processor used in the class
   * 
   */
  public Processor getProcessor() {
    return proc;
  }

  /**
   * returns the XQuery serializer used in the class
   */
  public Serializer getSerializer() {
    return serializer;
  }

  /**
   * Evaluate the XQuery query using the s9api of Saxon
   * 
   * @param query
   * @param out
   *          output
   */
  public String evaluate(final String query) throws Exception {
    Writer writer = new StringWriter();
    evaluate(new BufferedReader(new StringReader(query)), writer);

    return writer.toString();
  }

  /**
   * Evaluate the XQuery query using the s9api of Saxon
   * 
   * @param query
   * @param out
   *          output
   * @param vars
   *          list of external variables
   */
  public void evaluate(final String query, OutputStream out,
      Map<String, String> vars) throws Exception {

    if (vars != null) {
      xqueryExternalVars = vars;
    }

    this.evaluate(new BufferedReader(new StringReader(query)),
        new BufferedWriter(new OutputStreamWriter(out)));
  }

  /*
   * (non-Javadoc)
   * 
   * @see org.deri.xquery.XQueryEvaluator#setOmitXMLDecl(boolean)
   */
  public void setOmitXMLDecl(boolean xmloutput) {
    this.omitXMLDecl = xmloutput;

  }

  /**
   * 
   */
  private void initializeSerializer() {
    serializer = new Serializer();
    // can be xml, html, xhtml, or text.
    // TODO: possibly add parameter to the command line.
    serializer.setOutputProperty(Serializer.Property.METHOD,
        org.deri.xsparql.rewriter.Configuration.getOutputMethod());
    serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION,
        omitXMLDecl ? "yes" : "no");
    serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
  }

  public void evaluate(InputStream query, OutputStream out) throws Exception {
    evaluate(new BufferedReader(new InputStreamReader(query)),
        new BufferedWriter(new OutputStreamWriter(out)));
  }

  public void evaluate(Reader query, Writer out) throws Exception {
    serializer.setOutputWriter(out);

    // create a new XQuery compiler, this should be able to be reused,
    // see Saxon bug at:
    // http://sourceforge.net/tracker/?func=detail&aid=3008672&group_id=29872&atid=397617
    xqueryComp = proc.newXQueryCompiler();

    if (false && licensedVersion) {
      // BufferedReader xsdIn = new BufferedReader(new
      // InputStreamReader(XSPARQLProcessor.class.getResourceAsStream("/xquery/sparql.xsd")));
      // proc.getSchemaManager().load(new StreamSource(xsdIn));

      try {

        // final BufferedReader in = new BufferedReader(new
        // InputStreamReader(XSPARQLProcessor.class.getResourceAsStream("/xquery/xsparql.xquery")));
        final BufferedReader in = new BufferedReader(new InputStreamReader(
            XSPARQLProcessor.class.getResourceAsStream("/xsparql.xquery")));
        xqueryComp.compileLibrary(in);

      } catch (SaxonApiException e) {
        System.err.println(e.getMessage());
      }

    }

    net.sf.saxon.s9api.XQueryEvaluator evaluator = xqueryComp.compile(query)
        .load();

    for (String name : xqueryExternalVars.keySet()) {
      evaluator.setExternalVariable(new QName(name), new XdmAtomicValue(
          xqueryExternalVars.get(name)));
    }

    try {

      evaluator.run(serializer);

    } catch (SaxonApiException e) {
      throw new Exception(e.getMessage());
    }

  }

}