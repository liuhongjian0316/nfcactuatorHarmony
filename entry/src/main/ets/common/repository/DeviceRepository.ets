import relationalStore from '@ohos.data.relationalStore';
import { logger } from '../utils/Print';


export interface Device {
  appId?: string,
  tel?: string,
  code?: string,
  beginTime?: string,
  expireTime?: string,
  exitTime?: string,
  status?: string,
}

export interface DeviceResponse {
  id?: string,
  realName?: string,
  phone?: string,
  position?: string,
  company?: string,
  oaid?: string,
  appId?: string,
  appMaker?: string,
  appModal?: string,
  androidVersion?: string,
  androidVersionName?: string,
  appName?: string,
  appVersion?: string,
  appVersionCode?: string,
  imei?: string,
  ip?: string,
  status?: string,
  firstUseTime?: string,
  expireTime?: string,
  validTime?: string,
  atLastNetwork?: string,
  activationCode?: string,
  phoneStatus?: string,
  remark?: string,
  type?: string,
  limitedTime?: string,
  isUseTp?: string,
  productStatus?: string,
  productLevel?: string,
  permission?: string,
  index?: string,
  idString?: string,
  usestatus?: string,
}

export interface ConfigStatusAndLevel {
  status: string,
  level: string
}

export class DeviceRepository {
  private tableName = "DEVICE"
  private store = globalThis.rdbStore as relationalStore.RdbStore

  init() {

  }

  // 查询本地全部设备 理论只有一条
  selAll(): Device[] {
    let list: Device[] = []
    try {
      let predicates = new relationalStore.RdbPredicates(this.tableName);
      this.store.query(predicates, ['appId', 'tel', 'code', 'beginTime', 'expireTime', 'exitTime', 'status'], (err, resultSet) => {
        if (err) {
          console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
          return;
        }
        if (resultSet.rowCount > 0) {
          const appId = resultSet.getString(resultSet.getColumnIndex("appId"));
          const tel = resultSet.getString(resultSet.getColumnIndex("tel"));
          const code = resultSet.getString(resultSet.getColumnIndex("code"));
          const beginTime = resultSet.getString(resultSet.getColumnIndex("beginTime"));
          const expireTime = resultSet.getString(resultSet.getColumnIndex("expireTime"));
          const exitTime = resultSet.getString(resultSet.getColumnIndex("exitTime"));
          const status = resultSet.getString(resultSet.getColumnIndex("status"));
          list.push({
            appId: appId,
            tel: tel,
            code: code,
            beginTime: beginTime,
            expireTime: expireTime,
            exitTime: exitTime,
            status: status,
          })
        }
        resultSet.close()
      })
    } catch (e) {
      logger(JSON.stringify(e))
    }
    return list
  }

  // 插入单挑数据
  insert(device: Device) {
    const valueBucket = {
      appId: device?.appId || "",
      tel: device?.tel || "",
      code: device?.code || "",
      beginTime: device?.beginTime || "",
      expireTime: device?.expireTime || "",
      exitTime: device?.exitTime || "",
      status: device?.status || "",
    };

    this.store.insert(this.tableName, valueBucket, (err, rowId) => {
      if (err) {
        console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
        return;
      }
    })

  }

  // 清空表
  clearTable() {
    // 不添加条件删除所有数据
    let predicates = new relationalStore.RdbPredicates(this.tableName);
    this.store.delete(predicates, (err, rowId) => {
      if (err) {
        console.error(`Failed to delete data. Code:${err.code}, message:${err.message}`);
        return;
      }
    })
  }
}