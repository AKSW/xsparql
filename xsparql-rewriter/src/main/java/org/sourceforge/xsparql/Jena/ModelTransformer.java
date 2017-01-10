package org.sourceforge.xsparql.Jena;

import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.rdf.model.impl.StatementImpl;

import java.util.HashMap;
import java.util.function.Function;

/**
 * Created by Chile on 1/9/2017.
 */
public class ModelTransformer {
    private static HashMap<String, Function<Model, Model>> transformers = new HashMap<>();

    static{
        transformers.put("cleanLiterals", new Function<Model, Model>() {
            @Override
            public Model apply(Model model) {
                Model m = ModelFactory.createDefaultModel();
                StmtIterator si = model.listStatements();
                while (si.hasNext()) {
                    Statement stmt = si.nextStatement();
                    if (stmt.getObject().isLiteral()) {
                        Literal lit = stmt.getLiteral();
                        if (lit.getDatatype() == null) {
                            String zw = lit.getString().replaceAll("\\n", " ").replaceAll("\\s+", " ");
                            lit = m.createLiteral(zw, lit.getLanguage());
                        }
                        stmt = m.createStatement(stmt.getSubject(), stmt.getPredicate(), lit);
                    }
                    m.add(stmt);
                }
                return m;
            }
        });
        transformers.put("filterSkosLabels", new Function<Model, Model>() {
            @Override
            public Model apply(Model model) {
                Model m = ModelFactory.createDefaultModel();
                StmtIterator si = model.listStatements();
                while (si.hasNext()) {
                    Statement stmt = si.nextStatement();
                    String pred = stmt.getPredicate().getURI().trim();
                    if (pred.equals("http://www.w3.org/2004/02/skos/core#prefLabel") || pred.equals("http://www.w3.org/2004/02/skos/core#altLabel"))
                        m.add(stmt);
                }
                return m;
            }
        });
        transformers.put("addSkosAltLabels", new Function<Model, Model>() {
            @Override
            public Model apply(Model model) {
                Model m = ModelFactory.createDefaultModel();
                StmtIterator si = model.listStatements();
                while (si.hasNext()) {
                    Statement stmt = si.nextStatement();
                    String pred = stmt.getPredicate().getURI().trim();
                    if (pred.equals("http://www.w3.org/2004/02/skos/core#prefLabel"))
                    {
                        String[] altLabels = stmt.getLiteral().getString().split("\\s*,\\s*");
                        if(altLabels.length > 1) { //skip when only one label
                            for (int i = 0; i < altLabels.length; i++)
                            {
                                Literal lit = m.createLiteral(altLabels[i], stmt.getLiteral().getLanguage());
                                if(! model.listStatements(null, m.getProperty("http://www.w3.org/2004/02/skos/core#prefLabel"), lit).hasNext()) //no pref label is known with this literal!!
                                    m.add(new StatementImpl(stmt.getSubject(), m.getProperty("http://www.w3.org/2004/02/skos/core#altLabel"), lit));
                            }
                        }
                    }
                    m.add(stmt);
                }
                return m;
            }
        });
    }

    //TODO the default case is not opaque
    public static Function<Model, Model> getTransformer(String name) {
        return transformers.getOrDefault(name, new Function<Model, Model>() {
            @Override
            public Model apply(Model model) {return model;}
        });
    }
}
