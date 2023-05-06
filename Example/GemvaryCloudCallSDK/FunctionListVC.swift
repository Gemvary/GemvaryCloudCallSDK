//
//  FunctionListVC.swift
//  GemvaryCloudCallSDK_Example
//
//  Created by SongMengLong on 2023/4/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import GemvaryCloudCallSDK

/// 管理机列表
struct ManageList: Codable {
    /// 别名
    var alias: String?
    /// 设备码
    var devCode: String?
    /// 设备类型
    var devType: Int?
    /// 房间编号
    var roomno: String?
    /// 云对讲地址
    var sipAddr: String?
    /// 单元编号
    var unitno: String?
    /// 楼层号
    var floorNo: String?
}


/// 功能列表
class FunctionListVC: UIViewController {
    
    private let cellID: String = "FunctionListCell"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellID)
        return tableView
    }()
    
    private let dataList: [String] = ["呼叫管理机"]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 旧云对讲工具初始化 (暂时屏蔽功能)
        UCSCloudCallTool.share.ucsEngineSucess()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
     
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }

}

extension FunctionListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        cell.textLabel?.text = self.dataList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        swiftDebug("呼叫云对讲设备")
        UCSCloudCallTool.share.dial(callType: UCSCallType_VideoPhone, calledNumber: "jhrt2895", callerData: "管理机3288", type: "manager")
        // 0 可以呼叫
        // 1 余额不足
        // 2可以呼叫，管理机会主动挂断
    }
    
}

/// 门口机/室内机的数据
struct InOutdoorDev: Codable {
    /// 设备码
    var devCode: String?
    /// 设备类型
    var devType: Int?
    /// 设备说明
    var note: String?
    /// 云对讲账号
    var sipAddr: String?
    /// 单元号
    var unitno: String?
    /// 小区编号 数据库需要
    var zoneCode: String?
        
}

struct AccountInfo: Codable {
    /// 设置rowID
    var id: Int64?
    /// 账号
    var account: String?
    
    /// AbleCloud Token      /***   智慧社区相关字段   ** */
    var ablecloudToken: String?
    /// 云对讲类型
    var cloudIntercomType: Int?
    /// 是否为主账号
    var isPrimary: Int?
    /// 后台服务地址编号
    var serverId: String?
    /// SIP账号
    var sipId: String?
    ///  SIP密码
    var sipPassword: String?
    /// 云对讲服务器地址
    var sipServer: String?
    /// 手机免登录校验码
    var tokenauth: String?
    /// 手机免登录识别号
    var tokencode: String?
    /// 云之讯账号token
    var ucsToken: String?
    /// 判断登录用户是业主还是管理员
    var userDesc: Int?
    /// 用户ID
    var userId: Int?
    /// 免打扰状态
    var userStatus: Int?
    /// 室内机/C5-DS地址(有线安防地址)
    var indoorDevCode: String?
    
    
    /// 智能家居主机地址       /***   旧智能家居相关字段   ** */
    var smartDevCode: String?
    //var smartdevcode: String? // 智能家居主机数据
    /// MQTT Token
    var mqToken: String?
    /// MQTT Uid
    var mqUid: Int?
    /// AbleCloud Token
    var token: String?
    /// AbleCloud Uid
    var uid: Int?
    /// 是否是工程模式
    //var projectMode: Bool? = false
    /// 绑定类型
    var bindType: String? = "main"
    /// 局域网内设备的IP
    var server_ip: String? // 局域网设备IP
    /// 当前设备的平台
    var plat: String?
    
    /// 极光认证的Token     /***   新智能家居相关字段   ** */
    var loginToken: String?
    /// 鉴权token
    var access_token: String?
    /// 鉴权token时间
    var expires_in: Int?
    /// 刷新token
    var refresh_token: String?
    /// 刷新token时间
    var refresh_expires_in: Int?
    /// token类型
    var token_type: String?
    /// 当前主机 主机(新云端智能家居主机地址)
    var dev_addr: String?
    /// 当前主机的gid
    var gid: String?
    /// 昵称
    var nickname: String?
    /// 电话
    var phone: String?
    /// 头像路径
    var photo: String?
    /// 空间ID 新增字段(与智能家居dev_code字段一起用来区别是否为新旧状态) 2022.03.01
    var spaceID: String?
    
    /// 是否选中
    var selected: Bool?
    
}
