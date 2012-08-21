/*
 * Copyright (C) 2012 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1.  Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY GOOGLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GOOGLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef DOMTransaction_h
#define DOMTransaction_h

#if ENABLE(UNDO_MANAGER)

#include "UndoStep.h"
#include <wtf/RefPtr.h>

namespace WebCore {

class UndoManager;

class DOMTransaction : public UndoStep {
public:
    static PassRefPtr<DOMTransaction> create();

    void apply();
    virtual void unapply() OVERRIDE;
    virtual void reapply() OVERRIDE;

    virtual EditAction editingAction() const OVERRIDE { return EditActionUnspecified; }
    virtual bool isDOMTransaction() const OVERRIDE { return true; }

    UndoManager* undoManager() const { return m_undoManager; }
    void setUndoManager(UndoManager* undoManager) { m_undoManager = undoManager; }

private:
    DOMTransaction();

    UndoManager* m_undoManager;
};

}

#endif

#endif