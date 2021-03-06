//
//  ViewController.swift
//  taskapp
//
//  Created by Keiko Arita on 2016/10/03.
//  Copyright © 2016年 Keiko.Kurokawa. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // UISearchBarのデリゲート
        searchBar.delegate = self
        // キャンセルボタンの表示
        searchBar.showsCancelButton = true
        // プレースホルダの指定
        searchBar.placeholder = "検索文字列を入力してください"
        
    }
    
    // 検索ボタン(検索フィールド入力中のキーボードに表示)をタップした時の挙動
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // searchCategoryメソッドを実行する
        searchCategory()
        searchBar.text = ""
    }
    
    // 入力されている文字列をsearchWordに代入する
    func searchCategory() {
        let searchWord = searchBar.text
        print(searchWord)

        // 文字列で検索条件を指定する
        let query = "category = '\(searchWord!)'"

        // Taskのcategoryを完全一致で検索する
        taskArray = try! Realm().objects(Task).filter(query)
        // 画面を再描画する
        tableView.reloadData()
    }
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド

    // データの数（=セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
//        cell.textLabel?.text = task.title
        cell.textLabel?.text = task.category
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue",sender: nil)
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func searchBarSearchButtonClicked(searchBar:UISearchBar) {
//        print("検索ボタンがタップ scopeIndex=\(searchBar.selectedScopeButtonIndex)")
//    }
}

