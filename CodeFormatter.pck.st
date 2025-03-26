'From Cuis7.3 [latest update: #7087] on 25 March 2025 at 2:16:14 pm'!
'Description Reify rule to remove dots from last collaborations'!
!provides: 'CodeFormatter' 1 4!
SystemOrganization addCategory: #CodeFormatter!
SystemOrganization addCategory: #'CodeFormatter-AST'!
SystemOrganization addCategory: #'CodeFormatter-Rules'!
SystemOrganization addCategory: #'CodeFormatter-SourceCodeEditor'!


!classDefinition: #SourceCodeEditor category: #'CodeFormatter-SourceCodeEditor'!
Object subclass: #SourceCodeEditor
	instanceVariableNames: 'sourceCode numberOfRemovedCharacters removedCharacterPositionsInTheOriginalSourceCode emovedCharacterPositions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-SourceCodeEditor'!
!classDefinition: 'SourceCodeEditor class' category: #'CodeFormatter-SourceCodeEditor'!
SourceCodeEditor class
	instanceVariableNames: ''!

!classDefinition: #SynchronizedSourceRangeParseNodeVisitor category: #'CodeFormatter-AST'!
ParseNodeVisitor subclass: #SynchronizedSourceRangeParseNodeVisitor
	instanceVariableNames: 'rawSourceRanges'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-AST'!
!classDefinition: 'SynchronizedSourceRangeParseNodeVisitor class' category: #'CodeFormatter-AST'!
SynchronizedSourceRangeParseNodeVisitor class
	instanceVariableNames: ''!

!classDefinition: #SourceRangeCollectorParseNodeVisitor category: #'CodeFormatter-AST'!
SynchronizedSourceRangeParseNodeVisitor subclass: #SourceRangeCollectorParseNodeVisitor
	instanceVariableNames: 'collectedSourceRanges'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-AST'!
!classDefinition: 'SourceRangeCollectorParseNodeVisitor class' category: #'CodeFormatter-AST'!
SourceRangeCollectorParseNodeVisitor class
	instanceVariableNames: ''!

!classDefinition: #RemoveDotFromLastCollaborationCodeFormattingRule category: #'CodeFormatter-Rules'!
SynchronizedSourceRangeParseNodeVisitor subclass: #RemoveDotFromLastCollaborationCodeFormattingRule
	instanceVariableNames: 'methodNode sourceCodeEditor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-Rules'!
!classDefinition: 'RemoveDotFromLastCollaborationCodeFormattingRule class' category: #'CodeFormatter-Rules'!
RemoveDotFromLastCollaborationCodeFormattingRule class
	instanceVariableNames: ''!

!classDefinition: #SynchronizedSourceRangeParseNodeVisitorTest category: #'CodeFormatter-AST'!
TestCase subclass: #SynchronizedSourceRangeParseNodeVisitorTest
	instanceVariableNames: 'instanceVariable1 methodNode'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-AST'!
!classDefinition: 'SynchronizedSourceRangeParseNodeVisitorTest class' category: #'CodeFormatter-AST'!
SynchronizedSourceRangeParseNodeVisitorTest class
	instanceVariableNames: ''!

!classDefinition: #RemoveDotFromLastCollaborationCodeFormattingRuleTest category: #'CodeFormatter-Rules'!
TestCase subclass: #RemoveDotFromLastCollaborationCodeFormattingRuleTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-Rules'!
!classDefinition: 'RemoveDotFromLastCollaborationCodeFormattingRuleTest class' category: #'CodeFormatter-Rules'!
RemoveDotFromLastCollaborationCodeFormattingRuleTest class
	instanceVariableNames: ''!

!classDefinition: #RemoveCharacterAtPositionTest category: #'CodeFormatter-SourceCodeEditor'!
TestCase subclass: #RemoveCharacterAtPositionTest
	instanceVariableNames: 'sourceCodeEditor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CodeFormatter-SourceCodeEditor'!
!classDefinition: 'RemoveCharacterAtPositionTest class' category: #'CodeFormatter-SourceCodeEditor'!
RemoveCharacterAtPositionTest class
	instanceVariableNames: ''!


!SynchronizedSourceRangeParseNodeVisitor commentStamp: '<historical>' prior: 0!
I am an abstract superclass for ParseNode visitors that functions as a null visitor.  Here's the code that defines my interface:

(SystemNavigation default allImplementorsOf: #accept: localTo: ParseNode) do:
	[:methodReference|
	methodReference compiledMethod messages do:
		[:sel|
		((sel beginsWith: 'visit')
		and: [sel numArgs = 1]) ifTrue:
			[ParseNodeVisitor
				compile: (String streamContents:
							[:str|
							str nextPutAll: sel;
								space;
								nextPut: $a.
							methodReference classSymbol first isVowel ifTrue:
								[str nextPut: $n].
							str nextPutAll: methodReference classSymbol])
				classified: 'visiting']]]!

!SourceCodeEditor methodsFor: 'assertions' stamp: 'NPM 3/25/2025 12:43:25'!
assertIncludesPosition: aPositionInTheOriginalSourceCode

	^ (self includesPosition: aPositionInTheOriginalSourceCode)
		ifFalse: [ self error: self class positionOutOfRangeMessage ]! !

!SourceCodeEditor methodsFor: 'contents' stamp: 'NPM 3/23/2025 11:40:48'!
characterAt: aPositionInTheOriginalSourceCode

	^ sourceCode at: (self actualPositionOf: aPositionInTheOriginalSourceCode)! !

!SourceCodeEditor methodsFor: 'contents' stamp: 'NPM 3/23/2025 09:25:19'!
contents
	
	^ sourceCode! !

!SourceCodeEditor methodsFor: 'copying' stamp: 'NPM 3/23/2025 11:38:20'!
copyFromStartTo: aPositionInTheOriginalSourceCode 
	
	^ sourceCode
		copyFrom: 1
		to: (self actualPositionOf: aPositionInTheOriginalSourceCode)! !

!SourceCodeEditor methodsFor: 'copying' stamp: 'NPM 3/23/2025 11:51:46'!
copyToEndFrom: aPositionInTheOriginalSourceCode

	| originalPositionToCopyFrom |
	
	originalPositionToCopyFrom := (self isDeletedPosition: aPositionInTheOriginalSourceCode)
		ifTrue: [ aPositionInTheOriginalSourceCode + 1 ]
		ifFalse: [ aPositionInTheOriginalSourceCode ].

	^ sourceCode
		copyFrom: (self actualPositionOf: originalPositionToCopyFrom)
		to: sourceCode size ! !

!SourceCodeEditor methodsFor: 'initialization' stamp: 'NPM 3/23/2025 11:40:17'!
initializeOpen: aSourceCode
	
	sourceCode := aSourceCode.
	removedCharacterPositionsInTheOriginalSourceCode := SortedCollection new.! !

!SourceCodeEditor methodsFor: 'removing' stamp: 'NPM 3/23/2025 11:37:30'!
removeCharacter: aCharacter at: aPositionInTheOriginalSourceCode
	
	self assertIncludesPosition: aPositionInTheOriginalSourceCode.
	
	(self characterAt: aPositionInTheOriginalSourceCode is: aCharacter) 
		ifTrue: [ self removeCharacterAt: aPositionInTheOriginalSourceCode ]! !

!SourceCodeEditor methodsFor: 'removing' stamp: 'NPM 3/23/2025 11:46:53'!
removeCharacterAt: aPositionInTheOriginalSourceCode

	sourceCode := (self copyFromStartTo: aPositionInTheOriginalSourceCode - 1),(self copyToEndFrom: aPositionInTheOriginalSourceCode + 1).
	
	removedCharacterPositionsInTheOriginalSourceCode add: aPositionInTheOriginalSourceCode! !

!SourceCodeEditor methodsFor: 'removing' stamp: 'NPM 3/23/2025 17:23:02'!
tryToRemoveCharacter: aCharacter at: aPositionInTheOriginalSourceCode

	(self includesPosition: aPositionInTheOriginalSourceCode)
		ifTrue: [ self removeCharacter: aCharacter at: aPositionInTheOriginalSourceCode ]! !

!SourceCodeEditor methodsFor: 'testing' stamp: 'NPM 3/23/2025 11:40:48'!
characterAt: aPositionInTheOriginalSourceCode is: aCharacter

	^ (self characterAt: aPositionInTheOriginalSourceCode) = aCharacter! !

!SourceCodeEditor methodsFor: 'testing' stamp: 'NPM 3/23/2025 11:38:30'!
includesPosition: aPositionInTheOriginalSourceCode

	^(self actualPositionOf: aPositionInTheOriginalSourceCode)
		between: 1
		and: sourceCode size! !

!SourceCodeEditor methodsFor: 'testing' stamp: 'NPM 3/23/2025 11:41:36'!
isDeletedPosition: aPositionInTheOriginalSourceCode

	^ removedCharacterPositionsInTheOriginalSourceCode includes: aPositionInTheOriginalSourceCode! !

!SourceCodeEditor methodsFor: 'translating source code positions' stamp: 'NPM 3/23/2025 17:22:41'!
actualPositionOf: aPositionInTheOriginalSourceCode

	^ aPositionInTheOriginalSourceCode - (self numberOfCharactersRemovedOnOrBefore: aPositionInTheOriginalSourceCode)! !

!SourceCodeEditor methodsFor: 'translating source code positions' stamp: 'NPM 3/23/2025 11:40:17'!
numberOfCharactersRemovedOnOrBefore: aPositionInTheOriginalSourceCode

	^ removedCharacterPositionsInTheOriginalSourceCode count: [ :removedPosition | removedPosition <= aPositionInTheOriginalSourceCode ]! !

!SourceCodeEditor class methodsFor: 'instance creation' stamp: 'NPM 3/23/2025 09:22:30'!
open: aSourceCode
	
	^ self new
		initializeOpen: aSourceCode! !

!SourceCodeEditor class methodsFor: 'error messages' stamp: 'NPM 3/25/2025 12:43:05'!
positionOutOfRangeMessage
	
	^ 'Position is out of range'! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'source ranges' stamp: 'NPM 3/23/2025 19:10:23'!
consumeNextSourceRangeFor: aParseNode

	^ self
		nextSourceRangeFor: aParseNode
		consumeItIfPresent: true! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'source ranges' stamp: 'NPM 3/23/2025 19:12:29'!
nextSourceRangeFor: aParseNode consumeItIfPresent: consumeSourceRange 

	| sourceRange sourceRangeOrCollectionOfSourceRanges |
	
	sourceRangeOrCollectionOfSourceRanges := rawSourceRanges
		at: aParseNode
		ifAbsent: [ ^ nil ].
	
	sourceRangeOrCollectionOfSourceRanges isInterval ifTrue: [
		consumeSourceRange ifTrue: [ rawSourceRanges removeKey: aParseNode ].
		^ sourceRangeOrCollectionOfSourceRanges ].
	
	sourceRange := consumeSourceRange
		ifTrue: [ sourceRangeOrCollectionOfSourceRanges removeFirst ]
		ifFalse: [ sourceRangeOrCollectionOfSourceRanges first ].
	
	sourceRangeOrCollectionOfSourceRanges
		ifEmpty: [ rawSourceRanges removeKey: aParseNode ].

	^ sourceRange! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'source ranges' stamp: 'NPM 3/23/2025 19:10:29'!
peekNextSourceRangeFor: aParseNode

	^  self
		nextSourceRangeFor: aParseNode
		consumeItIfPresent: false! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:59:13'!
visitAssignmentNode: anAssignmentNode

	super visitAssignmentNode: anAssignmentNode.
	
	self consumeNextSourceRangeFor: anAssignmentNode.! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:59:33'!
visitBacktickNode: aBacktickNode

	super visitBacktickNode: aBacktickNode.

	self consumeNextSourceRangeFor: aBacktickNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/23/2025 17:24:12'!
visitBlockNode: aBlockNode

	self visitIfNotNil: aBlockNode temporariesDeclaration.
	
	self visitStatementsOf: aBlockNode.
		
	self consumeNextSourceRangeFor: aBlockNode.
	rawSourceRanges removeKey: aBlockNode closureCreationNode ifAbsent: [].! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:00:49'!
visitBraceNode: aBraceNode

	super visitBraceNode: aBraceNode.

	self consumeNextSourceRangeFor: aBraceNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:01:41'!
visitCascadeNode: aCascadeNode
	
	super visitCascadeNode: aCascadeNode.
		
	self consumeNextSourceRangeFor: aCascadeNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 00:51:20'!
visitInstanceVariableNode: anInstanceVariableNode

	self consumeNextSourceRangeFor: anInstanceVariableNode.! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 00:37:11'!
visitLiteralNode: aLiteralNode

	self consumeNextSourceRangeFor: aLiteralNode.! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 00:39:10'!
visitLiteralVariableNode: aLiteralVariableNode

	self consumeNextSourceRangeFor: aLiteralVariableNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:01:54'!
visitMessageNode: aMessageNode

	super visitMessageNode: aMessageNode.
	
	self consumeNextSourceRangeFor: aMessageNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:06:32'!
visitMessageNodeInCascade: aMessageNode
	
	super visitMessageNodeInCascade: aMessageNode.
		
	self consumeNextSourceRangeFor: aMessageNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/25/2025 12:35:20'!
visitMethodNode: aMethodNode
	
	rawSourceRanges := aMethodNode copyRawSourceRanges.

	super visitMethodNode: aMethodNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:36:24'!
visitNewArrayNode: aNewArrayNode

	self notYetImplemented! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:52:05'!
visitRemoteTempVectorNode: aRemoteTempVectorNode

	self notYetImplemented! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:02:45'!
visitReturnNode: aReturnNode

	super visitReturnNode: aReturnNode.
	
	self consumeNextSourceRangeFor: aReturnNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 00:21:41'!
visitSelectorNode: aSelectorNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/23/2025 17:24:12'!
visitStatementsOf: aBlockNode

	^ aBlockNode statementsDo:
		[ :statement| statement accept: self ]! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 00:56:09'!
visitTempVariableNode: aTempVariableNode

	self consumeNextSourceRangeFor: aTempVariableNode ! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:05:16'!
visitTemporariesDeclarationNode: aTemporariesDeclarationNode

	super visitTemporariesDeclarationNode: aTemporariesDeclarationNode.
	
	aTemporariesDeclarationNode declarationWritten ifTrue: [
		self consumeNextSourceRangeFor: aTemporariesDeclarationNode ]! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 02:05:32'!
visitTemporaryDeclarationNode: aTemporaryDeclarationNode

	super visitTemporaryDeclarationNode: aTemporaryDeclarationNode.
	
	self consumeNextSourceRangeFor: aTemporaryDeclarationNode! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:52:14'!
visitUndeclaredVariableNode: aVariableNode

	self notYetImplemented! !

!SynchronizedSourceRangeParseNodeVisitor methodsFor: 'visiting' stamp: 'NPM 3/22/2025 01:00:12'!
visitVariableNode: aVariableNode

	self consumeNextSourceRangeFor: aVariableNode! !

!SourceRangeCollectorParseNodeVisitor methodsFor: 'initialization' stamp: 'NPM 3/22/2025 02:07:54'!
initialize

	super initialize.
	collectedSourceRanges := OrderedCollection new.! !

!SourceRangeCollectorParseNodeVisitor methodsFor: 'source ranges' stamp: 'NPM 3/22/2025 02:08:02'!
collectedSourceRanges

	^ collectedSourceRanges! !

!SourceRangeCollectorParseNodeVisitor methodsFor: 'source ranges' stamp: 'NPM 3/25/2025 09:01:22'!
consumeNextSourceRangeFor: aParseNode

	(super consumeNextSourceRangeFor: aParseNode)
		ifNotNil: [ :sourceRange | collectedSourceRanges add: sourceRange ]! !

!RemoveDotFromLastCollaborationCodeFormattingRule methodsFor: 'editing source code' stamp: 'NPM 3/25/2025 14:16:02'!
applyTo: aMethodNode using: aSourceCodeEditor 
	
	methodNode := aMethodNode.
	sourceCodeEditor := aSourceCodeEditor.
	
	methodNode accept: self! !

!RemoveDotFromLastCollaborationCodeFormattingRule methodsFor: 'editing source code' stamp: 'NPM 3/23/2025 19:06:35'!
dotPositionFor: aParseNode

	^ (self peekNextSourceRangeFor: aParseNode) last + 1! !

!RemoveDotFromLastCollaborationCodeFormattingRule methodsFor: 'editing source code' stamp: 'NPM 3/25/2025 14:16:02'!
removeDotAfter: aParseNode

	sourceCodeEditor
		tryToRemoveCharacter: $.
		at: (self dotPositionFor: aParseNode)! !

!RemoveDotFromLastCollaborationCodeFormattingRule methodsFor: 'visiting' stamp: 'NPM 3/23/2025 09:12:41'!
visitMethodNode: aMethodNode 
	
	methodNode := aMethodNode.
	
	super visitMethodNode: aMethodNode ! !

!RemoveDotFromLastCollaborationCodeFormattingRule methodsFor: 'visiting' stamp: 'NPM 3/25/2025 10:27:58'!
visitStatementsOf: aBlockNode

	 (aBlockNode explicitStatementsIn: methodNode)
		allButLastDo: [ :statement | statement accept: self ]
		lastDo: [ :statement | 
				self removeDotAfter: statement.
				statement accept: self ]
			! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:13:51'!
allKindOfSourceRanges

	[].
	1.
	1! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:11:22'!
assert: aSelector isEquals: expectedSourceRanges

	| compiledMethod visitor  |
	
	compiledMethod := self class >> aSelector.
	methodNode := compiledMethod notOptimizedMethodNode.
	visitor := SourceRangeCollectorParseNodeVisitor new.
	methodNode accept: visitor.
	
	"
	 visitor sourceRanges asArray storeString copyToClipboard
	"
	self
		assert: (visitor collectedSourceRanges asArray)
		equals: expectedSourceRanges.
	! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:29:44'!
assignment

	instanceVariable1 := 1! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:28:17'!
backtick

	`1`! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:33:02'!
blockTemporaries

	[ | a b | ] ! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:26:40'!
brace

	{1. 1}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:28:02'!
bracex

	{}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:56:13'!
cascade

	self
		value;
		value! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:11:37'!
collectSourceRangesOfExampleMethodNamed: aSelector

	| compiledMethod sourceRangeCollector  |
	
	compiledMethod := self class >> aSelector.
	methodNode := compiledMethod notOptimizedMethodNode.
	
	sourceRangeCollector := SourceRangeCollectorParseNodeVisitor new.
	methodNode accept: sourceRangeCollector.
	
	"
	 visitor sourceRanges asArray storeString copyToClipboard
	"
	
	^sourceRangeCollector collectedSourceRanges asArray! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:22:30'!
emptyMethod! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:02:05'!
implicitSelfReturn! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:53:25'!
messageSend

	Array with: 1 with: 1! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 00:50:38'!
multipleInstanceVariables

	instanceVariable1.
	instanceVariable1! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 00:38:25'!
multipleLiteralVariables

	Object.
	Object! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 00:33:46'!
multipleLiterals

	1.
	1
	! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 00:54:23'!
multipleTemporaryVariablesInAMethod

	| temporary |
	
	temporary.
	temporary! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 00:57:55'!
multipleVariables

	true.
	true! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:18:30'!
return

	^ 1! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:04:37'!
temporaryDeclarations

	| a b |! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:24:52'!
test001

	self
		assert: #multipleLiterals
		isEquals: {(20 to: 20). (24 to: 24)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:24:56'!
test002

	self
		assert: #multipleLiteralVariables
		isEquals: {(28 to: 33) . (37 to: 42)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:25:00'!
test003

	self
		assert: #multipleInstanceVariables
		isEquals: {(29 to: 45) . (49 to: 65)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:05:48'!
test004

	self
		assert: #multipleTemporaryVariablesInAMethod
		isEquals: {(41 to: 49) . (41 to: 49) . (39 to: 51) . (56 to: 64) . (68 to: 76)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:25:14'!
test005

	self
		assert: #multipleVariables
		isEquals: {(21 to: 24) . (28 to: 31)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:25:36'!
test006

	self
		assert: #implicitSelfReturn
		isEquals: #()! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:05:57'!
test007

	self
		assert: #temporaryDeclarations
		isEquals: {(27 to: 27) . (27 to: 27) . (29 to: 29) . (29 to: 29) . (25 to: 30)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:06:06'!
test008

	self
		assert: #return
		isEquals: {(11 to: 12) . (10 to: 12)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:22:27'!
test009

	self
		assert: #emptyMethod
		isEquals: {}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:01:04'!
test010

	self
		assert: #brace
		isEquals: {(10 to: 10) . (13 to: 13) . (9 to: 14)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:01:15'!
test011

	self
		assert: #backtick
		isEquals: {(13 to: 13) . (12 to: 14)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:31:32'!
test012

	self
		assert: #assignment
		isEquals: {(34 to: 35) . (14 to: 30) . (32 to: 35)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 02:06:19'!
test013

	self
		assert: #blockTemporaries
		isEquals: {(24 to: 24) . (24 to: 24) . (26 to: 26) . (26 to: 26) . (22 to: 28) . (20 to: 30)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:55:40'!
test014

	self
		assert: #messageSend
		isEquals: {(15 to: 19) . (27 to: 27) . (34 to: 35) . (21 to: 35)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/22/2025 01:57:34'!
test015

	self
		assert: #cascade
		isEquals: {(11 to: 14) . (18 to: 22) . (27 to: 31) . (18 to: 31)}! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:17:37'!
test016

	self collectSourceRangesOfExampleMethodNamed: #multipleLiterals.
	
	self assert: methodNode encoder rawSourceRanges size equals: 1.
	self assert: methodNode encoder rawSourceRanges values first asArray equals: { (20 to: 20). (24 to: 24) }! !

!SynchronizedSourceRangeParseNodeVisitorTest methodsFor: 'as yet unclassified' stamp: 'NPM 3/25/2025 12:29:07'!
test017

	self collectSourceRangesOfExampleMethodNamed: #bracex.
	
	self assert: methodNode encoder rawSourceRanges size equals: 1.
	self assert: methodNode encoder rawSourceRanges values first equals: (10 to: 11)! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 10:22:14'!
test001_DoesNotFormatMethodsWithoutCollaborations

	self
		assertSourceCode: 'm1'
		isFormattedAs: 'm1'! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 10:23:11'!
test002_RemovesTheDotFromTheLastCollaboration

	self
		assertSourceCode: 'm1 1.'
		isFormattedAs: 'm1 1'! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 10:23:18'!
test003_DoesNotRemoveTheDotFromTheLastCollaborationWhenItDoesntHaveOne

	self
		assertSourceCode: 'm1 1'
		isFormattedAs: 'm1 1'! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 10:28:16'!
test004_RemovesTheDotFromNestedCollaborationsInTheLastOne

	self
		assertSourceCode: 'm1 [ 1. ]'
		isFormattedAs: 'm1 [ 1 ]'! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 10:28:44'!
test005_RemovesTheDotFromNestedCollaborations

	self
		assertSourceCode: 'm1 [ 1. ]. 2'
		isFormattedAs: 'm1 [ 1 ]. 2'! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'assertions' stamp: 'NPM 3/25/2025 10:31:26'!
assertSourceCode: anOriginalSourceCode isFormattedAs: anExpectedSourceCode
	
	self
		assert: (self format: anOriginalSourceCode)
		equals: anExpectedSourceCode! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'exercising' stamp: 'NPM 3/25/2025 13:02:35'!
compile: aSourceCode 

	SystemChangeNotifier uniqueInstance doSilently: [
		| selector |
			
		selector := self class
			compile: aSourceCode
			classified: 'test methods'.
							
		^ self class >> selector ]! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'exercising' stamp: 'NPM 3/25/2025 13:04:24'!
format: aSourceCode 

	| compiledMethodToFormat sourceCodeEditor |
	
	compiledMethodToFormat := self compile: aSourceCode.
	sourceCodeEditor := SourceCodeEditor open: compiledMethodToFormat sourceCode.
	
	RemoveDotFromLastCollaborationCodeFormattingRule new
		applyTo: compiledMethodToFormat methodNode
		using: sourceCodeEditor.
		
	^ sourceCodeEditor contents! !

!RemoveDotFromLastCollaborationCodeFormattingRuleTest methodsFor: 'test methods' stamp: 'NPM 3/25/2025 14:16:08'!
m1 [ 1. ]. 2! !

!RemoveCharacterAtPositionTest methodsFor: 'assertions' stamp: 'NPM 3/25/2025 12:50:05'!
assertEditedSourceCodeIs: anExpectedSourceCode

	self
		assert: sourceCodeEditor contents
		equals: anExpectedSourceCode! !

!RemoveCharacterAtPositionTest methodsFor: 'assertions' stamp: 'NPM 3/25/2025 12:52:21'!
denySourceCode: aSourceCode isChangedBecauseOutOfRangeErrorDuring: aBlock

	self
		denySourceCode: aSourceCode
		isChangedDuring: [ self shouldRaisePositionOutOfRangeError: aBlock ]! !

!RemoveCharacterAtPositionTest methodsFor: 'assertions' stamp: 'NPM 3/25/2025 12:51:24'!
denySourceCode: aSourceCode isChangedDuring: aBlock

	self open: aSourceCode.
	
	aBlock value.
	
	self assertEditedSourceCodeIs: aSourceCode! !

!RemoveCharacterAtPositionTest methodsFor: 'assertions' stamp: 'NPM 3/25/2025 12:42:37'!
shouldRaisePositionOutOfRangeError: aBlockClosure 
	
	self
		should: aBlockClosure
		raise: Error - MessageNotUnderstood
		withMessageText: SourceCodeEditor positionOutOfRangeMessage! !

!RemoveCharacterAtPositionTest methodsFor: 'exercising' stamp: 'NPM 3/25/2025 12:36:26'!
open: aSourceCode 
	
	sourceCodeEditor := SourceCodeEditor open: aSourceCode.! !

!RemoveCharacterAtPositionTest methodsFor: 'exercising' stamp: 'NPM 3/25/2025 12:39:31'!
removeCharacter: aCharacter at: aPositionInTheOriginalSourceCode
	
	sourceCodeEditor
		removeCharacter: aCharacter
		at: aPositionInTheOriginalSourceCode! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:52:56'!
test001_RemovesTheCharacterAtTheSpecifiedPosition

	self open: 'a'.
	
	self removeCharacter: $a at: 1.
	
	self assertEditedSourceCodeIs: ''! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:56:22'!
test002_DoesNotRemoveTheCharacterAtTheSpecifiedPositionWhenItDoesntMatchTheCharacterToRemove

	self open: 'b'.
	
	self removeCharacter: $a at: 1.
	
	self assertEditedSourceCodeIs: 'b'! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:57:11'!
test003_DoesNotRemoveCharactersWhenThePositionIsOutOfRange

	self
		denySourceCode: 'a'
		isChangedBecauseOutOfRangeErrorDuring: [ self removeCharacter: $a at: 0 ].
	self
		denySourceCode: 'a'
		isChangedBecauseOutOfRangeErrorDuring: [ self removeCharacter: $a at: 2 ]! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:58:22'!
test004_DoesNotChangeCharactersBeforeTheRemovedCharacter

	self open: 'ab'.
	
	self removeCharacter: $b at: 2.
	
	self assertEditedSourceCodeIs: 'a'! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:58:20'!
test005_DoesNotChangeCharactersAfterTheRemovedCharacter

	self open: 'ab'.
	
	self removeCharacter: $a at: 1.
	
	self assertEditedSourceCodeIs: 'b'! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 12:58:40'!
test006_RemovesACharacterBetweenCharacters

	self open: 'abc'.
	
	self removeCharacter: $b at: 2.
	
	self assertEditedSourceCodeIs: 'ac'! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 13:01:05'!
test007_RemovesACharacterWhenOneWasRemovedBeforeIt

	self open: 'abcd'.
	self removeCharacter: $b at: 2.
	
	self removeCharacter: $c at: 3.
	
	self assertEditedSourceCodeIs: 'ad'! !

!RemoveCharacterAtPositionTest methodsFor: 'tests' stamp: 'NPM 3/25/2025 13:01:20'!
test008_RemovesACharacterWhenOneWasRemovedAfterIt

	self open: 'abcd'.
	self removeCharacter: $c at: 3.
	
	self removeCharacter: $b at: 2.
	
	self assertEditedSourceCodeIs: 'ad'! !

!SequenceableCollection methodsFor: '*CodeFormatter' stamp: 'NPM 3/23/2025 10:01:16'!
allButLastDo: aBlockClosure lastDo: aBlockClosure2 
	
	self allButLastDo: aBlockClosure.
	self ifNotEmpty: [
	aBlockClosure2 value: self last ]! !

!Dictionary methodsFor: '*CodeFormatter' stamp: 'NPM 3/25/2025 12:34:18'!
copyValues
	
	^ self copy associationsDo: [ :association | association value: association value copy ]! !

!BlockNode methodsFor: '*CodeFormatter' stamp: 'NPM 3/23/2025 09:15:44'!
explicitStatementsIn: aMethodNode 
	
	^ statements reject: [ :statement | statement isImplicitSelfReturnIn: aMethodNode ]! !

!MethodNode methodsFor: '*CodeFormatter' stamp: 'NPM 3/25/2025 12:35:37'!
copyRawSourceRanges
	
	^ encoder rawSourceRanges copyValues! !
