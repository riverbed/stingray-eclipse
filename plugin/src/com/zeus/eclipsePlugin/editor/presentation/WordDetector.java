/*******************************************************************************
 * Copyright (C) 2013 Riverbed Technology, Inc and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Riverbed Technology - Main Implementation
 *     IBM Corporation - Code snippet     
 ******************************************************************************/

package com.zeus.eclipsePlugin.editor.presentation;

import org.eclipse.jface.text.rules.IWordDetector;

/**
 * Detector for functions/words
 */
public class WordDetector implements IWordDetector
{
   /* Override */
   public boolean isWordPart( char character )
   {
      return Character.isLetterOrDigit( character );
   }

   /* Override */
   public boolean isWordStart( char character )
   {
      return Character.isLetter( character ) || character == '.';
   }
}
