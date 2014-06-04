//
//  EMDropdownBox.m
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import "EMDropdownBox.h"

@implementation UIView (RoundCorners)

- (void)setAllRoundCorners:(CGFloat)radius {
    UIRectCorner corners = UIRectCornerAllCorners;
    [self setCorners:corners withRadius:radius];
}

- (void)setLeftRoundCorners:(CGFloat)radius {
    UIRectCorner corners = UIRectCornerBottomLeft | UIRectCornerTopLeft;
    [self setCorners:corners withRadius:radius];
}

- (void)setRightRoundCorners:(CGFloat)radius {
    UIRectCorner corners = UIRectCornerBottomRight | UIRectCornerTopRight;
    [self setCorners:corners withRadius:radius];
}

- (void)setTopRoundCorners:(CGFloat)radius {
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    [self setCorners:corners withRadius:radius];
}

- (void)setBottomRoundCorners:(CGFloat)radius {
    UIRectCorner corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    [self setCorners:corners withRadius:radius];
}

- (void)setCorners:(UIRectCorner)corners withRadius:(CGFloat)radius {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                       byRoundingCorners:corners
                                             cornerRadii:CGSizeMake(radius, radius)].CGPath;
    self.layer.mask = layer;
}

@end

@interface EMDropdownBox() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGRect dropdownRect;
@property (nonatomic, strong) UIView *tableViewContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) NSLayoutConstraint *tableHeight, *tableTop;
@property (nonatomic, assign) BOOL constraintsAdded;
@end

@implementation EMDropdownBox

- (id)init {
    self = [super init];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (void)initialise {
    self.titleLabel = [[UILabel alloc] init];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    
    self.titleColor = [UIColor colorWithRed:30.0f/255.0f
                                      green:170.0f/255.0f
                                       blue:178.0f/255.0f
                                      alpha:1.0];
    
    [self addSubview:self.titleLabel];
    
    _dropdownColor = [UIColor colorWithRed:131.0f/255.0f
                                     green:109.0f/255.0f
                                      blue:151.0f/255.0f
                                     alpha:1.0];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableViewContainer = [[UIView alloc] init];
    self.tableViewContainer.backgroundColor = [UIColor clearColor];
    self.tableViewContainer.hidden = YES;
    self.tableViewContainer.clipsToBounds = YES;
    [self.tableViewContainer addSubview:self.tableView];
    
    self.clipsToBounds = NO;
    [self addSubview:self.tableViewContainer];
    
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (!self.constraintsAdded) {
        self.constraintsAdded = YES;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _tableView,
                                                             _tableViewContainer);
        NSArray *constraints;
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-23-[_titleLabel]-46-|"
                                                              options:0
                                                              metrics:nil
                                                                views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_titleLabel]-0-|"
                                                              options:0
                                                              metrics:nil
                                                                views:views];
        [self addConstraints:constraints];
        
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableViewContainer]-0-|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[_tableViewContainer(1)]" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        for (NSLayoutConstraint *con in constraints) {
            if (con.constant == 1) {
                self.tableHeight = con;
            } else {
                self.tableTop = con;
            }
        }
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self createDropdown];
    self.tableView.layer.cornerRadius = 3.0;
    self.tableViewContainer.layer.masksToBounds = NO;
    
    // Add show to the table view container.
    self.tableViewContainer.layer.shadowOpacity = 0.3;
    self.tableViewContainer.layer.shadowRadius = 3;
    self.tableViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableViewContainer.layer.shadowOffset = CGSizeMake(0, 5);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, self.boxColor.CGColor);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.0];
    CGContextAddPath(ctx, path.CGPath);
    CGContextFillPath(ctx);
    
    // Draw the rect
    path = [UIBezierPath bezierPathWithRoundedRect:self.dropdownRect byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3.0, 3.0)];
    CGContextSetFillColorWithColor(ctx, self.dropdownColor.CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextFillPath(ctx);
    
    UIBezierPath *upArrowPath = [[UIBezierPath alloc] init];
    
    CGFloat x = self.dropdownRect.origin.x;
    CGFloat width = self.dropdownRect.size.width;
    CGFloat height = self.dropdownRect.size.height;
    
    [upArrowPath moveToPoint:CGPointMake(x + (width / 2 - 4), height / 2 - 5)];
    [upArrowPath addLineToPoint:CGPointMake(x + (width / 2), height / 2 - 9)];
    [upArrowPath addLineToPoint:CGPointMake(x + (width / 2 + 4), height / 2 - 5)];
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddPath(ctx, upArrowPath.CGPath);
    CGContextStrokePath(ctx);
    
    UIBezierPath *downArrowPath = [[UIBezierPath alloc] init];
    
    [downArrowPath moveToPoint:CGPointMake(x + (width / 2 - 4), height / 2 + 5)];
    [downArrowPath addLineToPoint:CGPointMake(x + (width / 2), height / 2 + 9)];
    [downArrowPath addLineToPoint:CGPointMake(x + (width / 2 + 4), height / 2 + 5)];
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddPath(ctx, downArrowPath.CGPath);
    CGContextStrokePath(ctx);
    
}

- (void)createDropdown {
    if (CGRectIsEmpty(self.dropdownRect)) {
        self.dropdownRect = CGRectMake(self.bounds.size.width - 44, 0, 44, self.bounds.size.height);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        UITouch * touch = [touches anyObject];
        // This is a simple tap
        CGPoint touchLocation = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.bounds, touchLocation)) {
            if (self.tableViewContainer.hidden) {
                
                self.tableViewContainer.hidden = NO;
                [self.superview bringSubviewToFront:self];
                
                self.tableHeight.constant = 150;
                [self.tableViewContainer setNeedsLayout];
                
                [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.tableViewContainer layoutIfNeeded];
                } completion:nil];
                
            } else {
                self.tableHeight.constant = 0;
                [self.tableViewContainer setNeedsLayout];
                [self.tableViewContainer layoutIfNeeded];
                self.tableViewContainer.hidden = YES;
            }
        }
    }
}

#pragma mark - Setters

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = self.titleColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setDropdownColor:(UIColor *)dropdownColor {
    _dropdownColor = dropdownColor;
    [self setNeedsDisplay];
}

- (void)setBoxColor:(UIColor *)boxColor {
    _boxColor = boxColor;
    self.tableView.backgroundColor = boxColor;
}

- (void)setTableData:(NSArray *)tableData {
    NSString *selected = nil;
    selected = self.tableData[self.selectedIndex];
    
    _tableData = tableData;
    
    
    [self.tableView reloadData];
    
    if (![tableData containsObject:selected]) {
        self.selectedIndex = 0;
    } else {
        self.selectedIndex = [self.tableData indexOfObject:selected];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (self.tableData && self.tableData.count > selectedIndex) {
        self.title = self.tableData[selectedIndex];
        NSIndexPath *path = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DropdownCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *label = [[UILabel alloc] init];
        label.tag = 5;
        [cell.contentView addSubview:label];
        cell.backgroundColor = [UIColor clearColor];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(label);
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[label]-5-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|"
                                                                                 options:0
                                                                                 metrics:nil
                                          
                                                                                   views:views]];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        bgView.backgroundColor = _dropdownColor;
        cell.selectedBackgroundView = bgView;
        
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:5];
    label.textColor = self.titleColor;
    label.font = self.titleFont;
    label.text = self.tableData[indexPath.row];
    
    if (self.selectedIndex == indexPath.row) {
        label.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:5];
    label.textColor = [UIColor whiteColor];
    self.selectedIndex = indexPath.row;
    self.tableHeight.constant = 0;
    [self.tableViewContainer setNeedsLayout];
    [self.tableViewContainer layoutIfNeeded];
    self.tableViewContainer.hidden = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownBox:didSelectIndex:)]) {
        [self.delegate dropdownBox:self didSelectIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:5];
    label.textColor = self.titleColor;
}

#pragma mark - Hit Test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
                break;
            }
        }
    }
    
    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}

@end
