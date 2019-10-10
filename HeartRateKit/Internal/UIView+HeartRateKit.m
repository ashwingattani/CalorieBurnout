#import "UIView+HeartRateKit.h"

#import <Availability.h>

@interface UIView (AutoLayoutPrivate)

/**
 *  Searches the view hierarchy to find the common superview between the receiver and the `peerView`.
 *
 *  @param peerView The other view in the view hierarchy where the superview should be located.
 *
 *  @return The common superview between the receiver and the `peerView` or nil if the views are not contained in the same view hierarchy.
 */
- (UIView*)commonSuperviewWithView:(UIView*)peerView;

/**
 *  Applys an attribute to the receiver with a specific constant and relation.
 *
 *  @param attribute The attribute of the receiver that you want to pin.
 *  @param constant  The constant that you want to apply to the constraint.
 *  @param relation  The relation that you wish to apply to the constraint.
 *
 *  @return The `NSLayoutConstraint` generated by this method.
 */
- (NSLayoutConstraint *)applyAttribute:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant relation:(NSLayoutRelation)relation;

@end

@implementation UIView (AutoLayout)

#pragma mark - Initializing a View Object

+(instancetype)hrkAutoLayoutView
{
    UIView *viewToReturn = [self new];
    viewToReturn.translatesAutoresizingMaskIntoConstraints = NO;
    return viewToReturn;
}

#pragma mark - Pinning to the Superview

-(NSArray*)hrkPinToSuperviewEdges:(HRKViewPinEdges)edges inset:(CGFloat)inset
{
    return [self hrkPinToSuperviewEdges:edges inset:inset usingLayoutGuidesFrom:nil];
}

- (NSArray *)hrkPinToSuperviewEdges:(HRKViewPinEdges)edges inset:(CGFloat)inset usingLayoutGuidesFrom:(UIViewController *)viewController
{
    UIView *superview = self.superview;
    NSAssert(superview,@"Can't pin to a superview if no superview exists");

    id topItem = nil;
    id bottomItem = nil;

#ifdef __IPHONE_7_0
    if (viewController && [viewController respondsToSelector:@selector(topLayoutGuide)])
    {
        topItem = viewController.topLayoutGuide;
        bottomItem = viewController.bottomLayoutGuide;
    }
#endif

    NSMutableArray *constraints = [NSMutableArray new];

    if (edges & HRKViewPinTopEdge)
    {
        id item = topItem ? topItem : superview;
        NSLayoutAttribute attribute = topItem ? NSLayoutAttributeBottom : NSLayoutAttributeTop;
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeTop toAttribute:attribute ofItem:item withConstant:inset]];
    }
    if (edges & HRKViewPinLeftEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeLeft ofItem:superview withConstant:inset]];
    }
    if (edges & HRKViewPinRightEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeRight toAttribute:NSLayoutAttributeRight ofItem:superview withConstant:-inset]];
    }
    if (edges & HRKViewPinBottomEdge)
    {
        id item = bottomItem ? bottomItem : superview;
        NSLayoutAttribute attribute = bottomItem ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeBottom toAttribute:attribute ofItem:item withConstant:-inset]];
    }
    return [constraints copy];
}


-(NSArray*)hrkPinToSuperviewEdgesWithInset:(UIEdgeInsets)insets
{
    NSMutableArray *constraints = [NSMutableArray new];

    [constraints addObjectsFromArray:[self hrkPinToSuperviewEdges:HRKViewPinTopEdge inset:insets.top]];
    [constraints addObjectsFromArray:[self hrkPinToSuperviewEdges:HRKViewPinLeftEdge inset:insets.left]];
    [constraints addObjectsFromArray:[self hrkPinToSuperviewEdges:HRKViewPinBottomEdge inset:insets.bottom]];
    [constraints addObjectsFromArray:[self hrkPinToSuperviewEdges:HRKViewPinRightEdge inset:insets.right]];

    return [constraints copy];
}

#pragma mark - Centering Views

-(NSArray *)hrkCenterInView:(UIView*)view
{
    NSMutableArray *constraints = [NSMutableArray new];

    [constraints addObject:[self hrkCenterInView:view onAxis:NSLayoutAttributeCenterX]];
    [constraints addObject:[self hrkCenterInView:view onAxis:NSLayoutAttributeCenterY]];

    return [constraints copy];
}

-(NSArray *)hrkCenterInContainer
{
    return [self hrkCenterInView:self.superview];
}

-(NSLayoutConstraint *)hrkCenterInContainerOnAxis:(NSLayoutAttribute)axis
{
    return [self hrkCenterInView:self.superview onAxis:axis];
}

-(NSLayoutConstraint *)hrkCenterInView:(UIView *)view onAxis:(NSLayoutAttribute)axis
{
    NSParameterAssert(axis == NSLayoutAttributeCenterX || axis == NSLayoutAttributeCenterY);
    return [self hrkPinAttribute:axis toSameAttributeOfItem:view];
}

#pragma mark - Constraining to a fixed size

-(NSArray *)hrkConstrainToSize:(CGSize)size
{
    NSMutableArray *constraints = [NSMutableArray new];

    if (size.width)
        [constraints addObject:[self hrkConstrainToWidth:size.width]];
    if (size.height)
        [constraints addObject:[self hrkConstrainToHeight:size.height]];

    return [constraints copy];
}

-(NSLayoutConstraint *)hrkConstrainToWidth:(CGFloat)width
{
    return [self hrkConstrainToWidth:width relation:NSLayoutRelationEqual];
}

-(NSLayoutConstraint *)hrkConstrainToWidth:(CGFloat)width relation:(NSLayoutRelation)relation
{
    return [self applyAttribute:NSLayoutAttributeWidth withConstant:width relation:relation];
}


-(NSLayoutConstraint *)hrkConstrainToHeight:(CGFloat)height
{
    return [self hrkConstrainToHeight:height relation:NSLayoutRelationEqual];
}

-(NSLayoutConstraint *)hrkConstrainToHeight:(CGFloat)height relation:(NSLayoutRelation)relation{
    return [self applyAttribute:NSLayoutAttributeHeight withConstant:height relation:relation];
}

-(NSArray *)hrkConstrainToMinimumSize:(CGSize)minimum maximumSize:(CGSize)maximum
{
    NSAssert(minimum.width <= maximum.width, @"maximum width should be strictly wider than or equal to minimum width");
    NSAssert(minimum.height <= maximum.height, @"maximum height should be strictly higher than or equal to minimum height");
    NSArray *minimumConstraints = [self hrkConstrainToMinimumSize:minimum];
    NSArray *maximumConstraints = [self hrkConstrainToMaximumSize:maximum];
    return [minimumConstraints arrayByAddingObjectsFromArray:maximumConstraints];
}

-(NSArray *)hrkConstrainToMinimumSize:(CGSize)minimum
{
    NSMutableArray *constraints = [NSMutableArray array];
    if (minimum.width)
        [constraints addObject:[self applyAttribute:NSLayoutAttributeWidth withConstant:minimum.width relation:NSLayoutRelationGreaterThanOrEqual]];
    if (minimum.height)
        [constraints addObject:[self applyAttribute:NSLayoutAttributeHeight withConstant:minimum.height relation:NSLayoutRelationGreaterThanOrEqual]];
    return [constraints copy];
}

-(NSArray *)hrkConstrainToMaximumSize:(CGSize)maximum
{
    NSMutableArray *constraints = [NSMutableArray array];
    if (maximum.width)
        [constraints addObject:[self applyAttribute:NSLayoutAttributeWidth withConstant:maximum.width relation:NSLayoutRelationLessThanOrEqual]];
    if (maximum.height)
        [constraints addObject:[self applyAttribute:NSLayoutAttributeHeight withConstant:maximum.height relation:NSLayoutRelationLessThanOrEqual]];
    return [constraints copy];
}

#pragma mark - Pinning to other items

- (NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem withConstant:(CGFloat)constant
{
    return [self hrkPinAttribute:attribute toAttribute:toAttribute ofItem:peerItem withConstant:constant relation:NSLayoutRelationEqual];
}

-(NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem
{
    return [self hrkPinAttribute:attribute toAttribute:toAttribute ofItem:peerItem withConstant:0];
}

-(NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofItem:(id)peerItem withConstant:(CGFloat)constant relation:(NSLayoutRelation)relation
{
    NSParameterAssert(peerItem);
    
    UIView *superview;
    if ([peerItem isKindOfClass:[UIView class]])
    {
        superview = [self commonSuperviewWithView:peerItem];
        NSAssert(superview,@"Can't create constraints without a common superview");
    }
    else
    {
        superview = self.superview;
    }
    NSAssert(superview,@"Can't create constraints without a common superview");

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:peerItem attribute:toAttribute multiplier:1.0 constant:constant];
    [superview addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfItem:(id)peerItem
{
    return [self hrkPinAttribute:attribute toAttribute:attribute ofItem:peerItem withConstant:0];
}

-(NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfItem:(id)peerItem withConstant:(CGFloat)constant
{
    return [self hrkPinAttribute:attribute toAttribute:attribute ofItem:peerItem withConstant:constant];
}

-(NSArray *)hrkPinEdges:(HRKViewPinEdges)edges toSameEdgesOfView:(UIView *)peerView
{
    return [self hrkPinEdges:edges toSameEdgesOfView:peerView inset:0];
}

-(NSArray*)hrkStackViews:(NSArray*)views
{
    if (!views || [views count] == 0) {
        return nil;
    }
    
    NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:([views count]+1)];
    if ([views count] == 1) {
        UIView *view = [views firstObject];
        NSLayoutConstraint * constraint = [self hrkPinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeTop ofItem:view];
        [constraints addObject:constraint];
        constraint = [self hrkPinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeBottom ofItem:view];
        [constraints addObject:constraint];
    }
    else{
        UIView *prevView = [views firstObject];
        for (UIView *currView in views){
            if (currView == views.firstObject) {
                NSLayoutConstraint * constraint = [self hrkPinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeTop ofItem:currView];
                [constraints addObject:constraint];
            }
            else if(currView == views.lastObject){
                NSLayoutConstraint * constraint = [prevView hrkPinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeTop ofItem:currView];
                [constraints addObject:constraint];
                constraint = [self hrkPinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeBottom ofItem:currView];
                [constraints addObject:constraint];
            }
            else{
                NSLayoutConstraint * constraint = [prevView hrkPinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeTop ofItem:currView];
                [constraints addObject:constraint];
            }
            prevView=currView;
        }
    }
    return constraints;
}

-(NSArray *)hrkPinEdges:(HRKViewPinEdges)edges toSameEdgesOfView:(UIView *)peerView inset:(CGFloat)inset
{
    UIView *superview = [self commonSuperviewWithView:peerView];
    NSAssert(superview,@"Can't create constraints without a common superview");
    
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:4];
    
    if (edges & HRKViewPinTopEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeTop ofItem:peerView withConstant:inset]];
    }
    if (edges & HRKViewPinLeftEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeLeft ofItem:peerView withConstant:inset]];
    }
    if (edges & HRKViewPinRightEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeRight toAttribute:NSLayoutAttributeRight ofItem:peerView withConstant:-inset]];
    }
    if (edges & HRKViewPinBottomEdge)
    {
        [constraints addObject:[self hrkPinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeBottom ofItem:peerView withConstant:-inset]];
    }
    [superview addConstraints:constraints];
    return [constraints copy];
}

#pragma mark - Pinning to a fixed point

-(NSArray*)hrkPinPointAtX:(NSLayoutAttribute)x Y:(NSLayoutAttribute)y toPoint:(CGPoint)point
{
    UIView *superview = self.superview;
    NSAssert(superview,@"Can't create constraints without a superview");
    
    // Valid X positions are Left, Center, Right and Not An Attribute
    __unused BOOL xValid = (x == NSLayoutAttributeLeft || x == NSLayoutAttributeCenterX || x == NSLayoutAttributeRight || x == NSLayoutAttributeNotAnAttribute);
    // Valid Y positions are Top, Center, Baseline, Bottom and Not An Attribute
    __unused BOOL yValid = (y == NSLayoutAttributeTop || y == NSLayoutAttributeCenterY || y == NSLayoutAttributeBaseline || y == NSLayoutAttributeBottom || y == NSLayoutAttributeNotAnAttribute);
    
    NSAssert (xValid && yValid,@"Invalid positions for creating constraints");
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    if (x != NSLayoutAttributeNotAnAttribute)
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:x relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:point.x];
        [constraints addObject:constraint];
    }
    
    if (y != NSLayoutAttributeNotAnAttribute)
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:y relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:point.y];
        [constraints addObject:constraint];
    }
    [superview addConstraints:constraints];
    return [constraints copy];
}

#pragma mark - Spacing Views

-(NSArray*)hrkSpaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options
{
    return [self hrkSpaceViews:views onAxis:axis withSpacing:spacing alignmentOptions:options flexibleFirstItem:NO];
}

-(NSArray*)hrkSpaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options flexibleFirstItem:(BOOL)flexibleFirstItem
{
    return [self hrkSpaceViews:views onAxis:axis withSpacing:spacing alignmentOptions:options flexibleFirstItem:flexibleFirstItem applySpacingToEdges:YES];
}

-(NSArray*)hrkSpaceViews:(NSArray*)views onAxis:(UILayoutConstraintAxis)axis withSpacing:(CGFloat)spacing alignmentOptions:(NSLayoutFormatOptions)options flexibleFirstItem:(BOOL)flexibleFirstItem applySpacingToEdges:(BOOL)spaceEdges
{
    NSAssert([views count] > 1,@"Can only distribute 2 or more views");
    NSString *direction = nil;
    NSLayoutAttribute attribute;
    switch (axis) {
        case UILayoutConstraintAxisHorizontal:
            direction = @"H:";
            attribute = NSLayoutAttributeWidth;
            break;
        case UILayoutConstraintAxisVertical:
            direction = @"V:";
            attribute = NSLayoutAttributeHeight;
            break;
        default:
            return @[];
    }
    
    UIView *previousView = nil;
    UIView *firstView = views[0];
    NSDictionary *metrics = @{@"spacing":@(spacing)};
    NSString *hrkl = nil;
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in views)
    {
        hrkl = nil;
        NSDictionary *views = nil;
        if (previousView)
        {
            if (previousView == firstView && flexibleFirstItem)
            {
                hrkl = [NSString stringWithFormat:@"%@[previousView(>=view)]-spacing-[view]",direction];
            }
            else
            {
                hrkl = [NSString stringWithFormat:@"%@[previousView(==view)]-spacing-[view]",direction];
            }
            views = NSDictionaryOfVariableBindings(previousView,view);
        }
        else
        {
            hrkl = [NSString stringWithFormat:@"%@|%@[view]",direction, spaceEdges ? @"-spacing-" : @""];
            views = NSDictionaryOfVariableBindings(view);
        }
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:hrkl options:options metrics:metrics views:views]];
        if (previousView == firstView && flexibleFirstItem)
        {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:firstView attribute:attribute relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:attribute multiplier:1.0 constant:2.0]];
        }
        previousView = view;
    }
    
    hrkl = [NSString stringWithFormat:@"%@[previousView]%@|",direction, spaceEdges ? @"-spacing-" : @""];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:hrkl options:options metrics:metrics views:NSDictionaryOfVariableBindings(previousView)]];
    
    [self addConstraints:constraints];
    return [constraints copy];
}

-(NSArray*)hrkSpaceViews:(NSArray *)views onAxis:(UILayoutConstraintAxis)axis
{
    NSAssert([views count] > 1,@"Can only distribute 2 or more views");

    NSLayoutAttribute attributeForView;
    NSLayoutAttribute attributeToPin;

    switch (axis) {
        case UILayoutConstraintAxisHorizontal:
            attributeForView = NSLayoutAttributeCenterX;
            attributeToPin = NSLayoutAttributeRight;
            break;
        case UILayoutConstraintAxisVertical:
            attributeForView = NSLayoutAttributeCenterY;
            attributeToPin = NSLayoutAttributeBottom;
            break;
        default:
            return @[];
    }

    CGFloat fractionPerView = 1.0 / (CGFloat)([views count] + 1);
    
    NSMutableArray *constraints = [NSMutableArray array];
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
    {
        CGFloat multiplier = fractionPerView * (idx + 1.0);
        [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:attributeForView relatedBy:NSLayoutRelationEqual toItem:self attribute:attributeToPin multiplier:multiplier constant:0.0]];
    }];
    
    [self addConstraints:constraints];
    return [constraints copy];
}

#pragma mark - Private

-(UIView*)commonSuperviewWithView:(UIView*)peerView
{
    UIView *commonSuperview = nil;
    UIView *startView = self;
    do {
        if ([peerView isDescendantOfView:startView])
        {
            commonSuperview = startView;
        }
        startView = startView.superview;
    } while (startView && !commonSuperview);
    
    return commonSuperview;
}

-(NSLayoutConstraint *)applyAttribute:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant relation:(NSLayoutRelation)relation
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
    [self addConstraint:constraint];
    return constraint;
}

#pragma mark - Deprecated

-(NSLayoutConstraint *)hrkPinAttribute:(NSLayoutAttribute)attribute toSameAttributeOfView:(UIView *)peerView
{
    return [self hrkPinAttribute:attribute toSameAttributeOfItem:peerView];
}

-(NSLayoutConstraint *)hrkPinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView*)peerView
{
    return [self hrkPinEdge:edge toEdge:toEdge ofItem:peerView inset:0.0];
}

-(NSLayoutConstraint *)hrkPinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)peerView inset:(CGFloat)inset
{
    return [self hrkPinEdge:edge toEdge:toEdge ofItem:peerView inset:inset];
}

- (NSLayoutConstraint *)hrkPinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem
{
    return [self hrkPinEdge:edge toEdge:toEdge ofItem:peerItem inset:0.0];
}

- (NSLayoutConstraint *)hrkPinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem inset:(CGFloat)inset
{
    return [self hrkPinEdge:edge toEdge:toEdge ofItem:peerItem inset:inset relation:NSLayoutRelationEqual];
}

-(NSLayoutConstraint *)hrkPinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofItem:(id)peerItem inset:(CGFloat)inset relation:(NSLayoutRelation)relation
{
    return [self hrkPinAttribute:edge toAttribute:toEdge ofItem:peerItem withConstant:inset relation:relation];
}

@end
