/*******************************************************************************
 * Copyright (C) 2013 Riverbed Technology, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Riverbed Technology - Main Implementation
 ******************************************************************************/

package com.zeus.eclipsePlugin.editor.presentation;

import org.eclipse.jface.text.rules.IWordDetector;

/**
 * Detector that matches TrafficScript variables (e.g. $foo, $bar)
 */
public class VariableDetecter implements IWordDetector
{

   /* Override */
   public boolean isWordPart( char c )
   {
      return Character.isLetterOrDigit( c ) || c == '_';
   }

   /* Override */
   public boolean isWordStart( char c )
   {
      return c == '$';
   }

}
