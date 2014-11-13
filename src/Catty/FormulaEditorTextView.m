/**
 *  Copyright (C) 2010-2014 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "FormulaEditorTextView.h"
#import "FormulaEditorViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BrickCell.h"
#import "BrickFormulaProtocol.h"
#import "Formula.h"
#import <UIKit/UIKit.h>

@interface FormulaEditorTextView ()
@property (nonatomic, weak) FormulaEditorViewController *formulaEditorViewController;
@property (nonatomic, strong) UIButton *backspaceButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@end

@implementation FormulaEditorTextView

#define TEXT_FIELD_PADDING_HORIZONTAL 5
#define TEXT_FIELD_PADDING_VERTICAL 10
#define TEXT_FIELD_MARGIN_BOTTOM 2
#define BACKSPACE_HEIGHT 28
#define BACKSPACE_WIDTH 28

- (id)initWithFrame:(CGRect)frame AndFormulaEditorViewController:(FormulaEditorViewController*)formulaEditorViewController
{
    self = [super initWithFrame:frame];
    self.formulaEditorViewController = formulaEditorViewController;
    if (self) {
        self.delegate = self;
        self.gestureRecognizers = nil;
        //self.selectable = NO;
        [self addGestureRecognizer:self.tapRecognizer];
        self.inputView = [[[NSBundle mainBundle] loadNibNamed:@"FormulaEditor" owner:self.formulaEditorViewController options:nil] lastObject];
        self.inputView.backgroundColor = UIColor.airForceBlueColor;
        self.userInteractionEnabled = YES;
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont boldSystemFontOfSize:20.0f];
        
        self.contentInset = UIEdgeInsetsZero;
        self.textContainerInset = UIEdgeInsetsMake(TEXT_FIELD_PADDING_VERTICAL, TEXT_FIELD_PADDING_HORIZONTAL, TEXT_FIELD_PADDING_VERTICAL, TEXT_FIELD_PADDING_HORIZONTAL + BACKSPACE_WIDTH);
        
        self.backspaceButton = [[UIButton alloc] init];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
        [self.backspaceButton setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateDisabled];
        self.backspaceButton.tintColor = UIColor.airForceBlueColor;
        self.backspaceButton.frame = CGRectMake(self.frame.size.width - BACKSPACE_WIDTH, 0, BACKSPACE_HEIGHT, BACKSPACE_WIDTH);
        [self.backspaceButton addTarget:self.formulaEditorViewController action:@selector(backspace:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backspaceButton];
    }
    return self;
}

-(UITapGestureRecognizer *)tapRecognizer
{
    if (!_tapRecognizer) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(formulaTapped:)];
    }
    return _tapRecognizer;
}


#pragma mark - TextField properties
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (BOOL)isTextSelectable
{
    return NO;
}

- (BOOL)isHighlighted
{
    return NO;
}

- (BOOL)isTracking
{
    return NO;
}



- (void)formulaTapped:(UITapGestureRecognizer *)recognizer
{
    UITextView *formulaView = (UITextView *)recognizer.view;
    CGPoint point = [recognizer locationInView:formulaView];
    point.x -= formulaView.textContainerInset.left;
    point.y -= formulaView.textContainerInset.top;
    
    NSLayoutManager *layoutManager = formulaView.layoutManager;
    NSUInteger cursorPostionIndex = [layoutManager characterIndexForPoint:point
                                                          inTextContainer:formulaView.textContainer
                                 fractionOfDistanceBetweenInsertionPoints:NULL] + 1;
    [self.formulaEditorViewController.internFormula setCursorAndSelection:(int)cursorPostionIndex selected:NO];
    int startIndex = [self.formulaEditorViewController.internFormula getExternSelectionStartIndex];
    int endIndex = [self.formulaEditorViewController.internFormula getExternSelectionEndIndex];
    
    [self highlightSelection:cursorPostionIndex start:startIndex end:endIndex];
    
    
}

-(void)highlightSelection:(NSUInteger)cursorPostionIndex start:(int)startIndex end:(int)endIndex
{
    NSMutableAttributedString *formulaString = [[NSMutableAttributedString alloc] initWithString:[self text] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f]}];
    
    
    
    UITextPosition* beginning = self.beginningOfDocument;
    UITextPosition *cursorPositionStart = [self positionFromPosition:beginning
                                                                    offset:startIndex];
    UITextPosition *cursorPositionEnd = [self positionFromPosition:beginning
                                                                  offset:endIndex];
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:cursorPositionStart];
    NSInteger length = [self offsetFromPosition:cursorPositionStart toPosition:cursorPositionEnd];
    
    NSLog(@"tap from %d to %d!", startIndex, endIndex);
    
    if(startIndex == endIndex)
    {
        self.attributedText = formulaString;
        UITextPosition *cursorPosition = [self positionFromPosition:self.beginningOfDocument
                                                                   offset:cursorPostionIndex];
        self.selectedTextRange = [self textRangeFromPosition:cursorPosition toPosition:cursorPosition];
    }
    else{
        [formulaString addAttribute:NSBackgroundColorAttributeName value:[UIColor lightOrangeColor] range:NSMakeRange(location, length)];
        UITextPosition *cursorPosition = [self positionFromPosition:self.beginningOfDocument
                                                                   offset:endIndex];
        self.attributedText = formulaString;
        self.selectedTextRange = [self textRangeFromPosition:cursorPosition toPosition:cursorPosition];
        
    }
    
    
    [self.formulaEditorViewController.history updateCurrentSelection:[self.formulaEditorViewController.internFormula getSelection]];
    [self.formulaEditorViewController.history updateCurrentCursor:(int)cursorPostionIndex];
}

-(void)highlightAll
{
    
}

- (void)update
{
    [self.formulaEditorViewController.internFormula generateExternFormulaStringAndInternExternMapping];
    [self.formulaEditorViewController.internFormula updateInternCursorPosition];
    NSMutableAttributedString *formulaString = [[NSMutableAttributedString alloc] initWithString:[self.formulaEditorViewController.internFormula getExternFormulaString]
                                                                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f]}];
    
    self.attributedText = formulaString;
    //[self.formulaEditorViewController.internFormula setCursorAndSelection:(int)[self.formulaEditorViewController.internFormula getExternCursorPosition] selected:NO];
    [self highlightSelection:[self.formulaEditorViewController.internFormula getExternCursorPosition]
                       start:[self.formulaEditorViewController.internFormula getExternSelectionStartIndex]
                         end:[self.formulaEditorViewController.internFormula getExternSelectionEndIndex]];
    
    if([self.formulaEditorViewController.internFormula isEmpty]) {
        self.backspaceButton.enabled = NO;
        self.backspaceButton.alpha = 0.3;
    } else {
        self.backspaceButton.enabled = YES;
        self.backspaceButton.alpha = 1.0;
    }
}
   
- (void)setAttributedText:(NSMutableAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self layoutIfNeeded];
    
    CGRect frame = self.frame;
    frame.size.height = self.contentSize.height;
    
    float maxHeight = [[UIScreen mainScreen] bounds].size.height - self.frame.origin.y - self.inputView.frame.size.height - TEXT_FIELD_MARGIN_BOTTOM;
    if(frame.size.height > maxHeight)
        frame.size.height = maxHeight;
    
    self.frame = frame;
    [self scrollRangeToVisible:NSMakeRange(self.text.length - 1, 1)];
    
    CGRect backspaceFrame = self.backspaceButton.frame;
    backspaceFrame.origin.y = self.contentSize.height - TEXT_FIELD_PADDING_VERTICAL - self.font.lineHeight/2 - self.backspaceButton.frame.size.height/2;
    self.backspaceButton.frame = backspaceFrame;
}



@end
