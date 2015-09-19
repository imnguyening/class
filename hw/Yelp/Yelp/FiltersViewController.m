//
//  FiltersViewController.m
//  Yelp
//
//  Created by Minh Nguyen on 9/17/15.
//  Copyright (c) 2015 Minh Nguyen. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchTableViewCell.h"

@interface FiltersViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property Boolean distanceExpanded;
@property Boolean sortExpanded;

//Local values
@property (weak, nonatomic) SwitchTableViewCell *dealsCell;
@property (strong, nonatomic) NSMutableArray *categoryCells;
@property NSInteger radiusFilterIndex;
@property NSInteger sortFilterIndex;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.distanceExpanded = false;
    self.sortExpanded = false;
    
    NSArray *filtersRadiusArray = FiltersRadiusArray;
    unsigned int i;
    for (i=0;i<filtersRadiusArray.count;i++) {
        //NSLog(@"value: %f", [filtersRadiusArray[i] floatValue]);
        if (self.filters.radius_filter == [filtersRadiusArray[i] floatValue]) {
            self.radiusFilterIndex = i;
        }
    }
    self.sortFilterIndex = self.filters.sort;
    self.categoryCells = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section)
    {
        case 0:
            // Deals row
            return @"";
        case 1:
            return @"Distance";
        case 2:
            return @"Sort By";
        case 3:
            return @"Categories";
        default:
            return @"";
    }
}
/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
    if (section > 0)
        [headerView setBackgroundColor:[UIColor redColor]];
    else
        [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section)
    {
        case 0: // Deals
            return 1;
            break;
        case 1: // Distance
            return (self.distanceExpanded) ? FiltersDistanceNamesArray.count : 1;
            break;
        case 2: //Sort
            return (self.sortExpanded) ? FiltersSortNamesArray.count : 1;
            break;
        case 3: // Categories
            return FilterCategoriesArray.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 0: {
            return [self generateDealsCellAtIndexPath:indexPath];
            break;
        }
        case 1:
            return [self generateDistanceCellAtIndexPath:indexPath];
        case 2:
            return [self generateSortCellAtIndexPath:indexPath];
        case 3:
            return [self generateCategoryCellAtIndexPath:indexPath];
        default: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            return cell;
            break;
        }
    }
}

//Section 0
- (SwitchTableViewCell *) generateDealsCellAtIndexPath:(NSIndexPath*)indexPath {
    SwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"com.yahoo.yelp.filters.switch.cell"];
    cell.nameLabel.text = @"Offering a Deal";
    
    if (self.filters.deals_filter == true) {
        [cell.settingSwitch setOn:true];
    }
    
    self.dealsCell = cell;
    return cell;
}

// Section 1
-(UITableViewCell *) generateDistanceCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.distanceExpanded) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSArray *namesArray = FiltersDistanceNamesArray;
        NSString *currentText = namesArray[indexPath.row];
        cell.textLabel.text = currentText;
        
        if (self.radiusFilterIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSArray *namesArray = FiltersDistanceNamesArray;
        NSString *currentText = namesArray[self.radiusFilterIndex];
        cell.textLabel.text = currentText;
        
        UIImage *image = [UIImage imageNamed:@"down128.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 20, 20);
        cell.accessoryView = imageView;
        
        return cell;
    }
}

// Section 2
-(UITableViewCell *) generateSortCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sortExpanded) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSArray *namesArray = FiltersSortNamesArray;
        NSString *currentText = namesArray[indexPath.row];
        cell.textLabel.text = currentText;
        
        if (self.sortFilterIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSArray *namesArray = FiltersSortNamesArray;
        NSString *currentText = namesArray[self.sortFilterIndex];
        cell.textLabel.text = currentText;
        
        UIImage *image = [UIImage imageNamed:@"down128.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 20, 20);
        cell.accessoryView = imageView;
        
        return cell;
    }
}

// Section 3
- (SwitchTableViewCell *) generateCategoryCellAtIndexPath:(NSIndexPath*)indexPath  {
    SwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"com.yahoo.yelp.filters.switch.cell"];
    NSArray *categoryNames = FilterCategoriesNamesArray;
    cell.nameLabel.text = categoryNames[indexPath.row];
    
    if ([self.filters.category_filter_array[indexPath.row] boolValue] == true) {
        [cell.settingSwitch setOn:true];
    }
    
    [self.categoryCells addObject:cell];
    return cell;
}

// Select rows in Section 2 or 3
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 1: {
            if (self.distanceExpanded) {
                self.distanceExpanded = false;
                self.radiusFilterIndex = indexPath.row;
            } else {
                self.distanceExpanded = true;
            }
            [UIView transitionWithView:self.tableView duration:0.35f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
                 [tableView reloadData];
             } completion:nil];
            break;
        }
        case 2: {
            if (self.sortExpanded) {
                self.sortExpanded = false;
                self.sortFilterIndex = indexPath.row;
            } else {
                self.sortExpanded = true;
            }
            [UIView transitionWithView:self.tableView duration:0.35f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
                [tableView reloadData];
            } completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UI
- (IBAction)searchTapped:(UIBarButtonItem *)sender {
    //NSLog(@"Deals Value: %@", [self.dealsCell.settingSwitch isOn] ? @"Yes":@"No");
    self.filters.deals_filter = [self.dealsCell.settingSwitch isOn];
    
    NSArray *filtersRadiusArray = FiltersRadiusArray;
    self.filters.radius_filter = [filtersRadiusArray[self.radiusFilterIndex] floatValue];
    self.filters.sort = self.sortFilterIndex;
    
    unsigned int i;
    for (i=0;i<self.filters.category_filter_array.count;i++) {
        SwitchTableViewCell *cell = self.categoryCells[i];
        self.filters.category_filter_array[i] = [NSNumber numberWithBool:[cell.settingSwitch isOn]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FilterViewSavedNotification object:self];
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
