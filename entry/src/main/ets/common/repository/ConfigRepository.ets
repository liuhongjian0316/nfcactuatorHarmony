import relationalStore from '@ohos.data.relationalStore';
import { logger } from '../utils/Print';


export interface Config {
  id?: string,
  keyname: string,
  status: string,
  level: string,
}

export interface ConfigResponse {
  id?: string,
  name?: string,
  keyName?: string,
  createTime?: Date,
  updayeTime?: Date,
  description?: string,
  type?: string,
  status?: string,
  level?: string,
  index?: string,
}


export class ConfigRepository {
  private tableName = "CONFIG"
  private store = globalThis.rdbStore as relationalStore.RdbStore

  // 查询全部数据
  selAll(): Config[] {
    let list: Config[] = []
    let predicates = new relationalStore.RdbPredicates(this.tableName);
    this.store.query(predicates, ['id', 'keyname', 'status', 'level'], (err, resultSet) => {
      if (err) {
        console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
        return;
      }
      if (resultSet.rowCount > 0) {
        const id = resultSet.getString(resultSet.getColumnIndex("id"));
        const keyname = resultSet.getString(resultSet.getColumnIndex("keyname"));
        const status = resultSet.getString(resultSet.getColumnIndex("status"));
        const level = resultSet.getString(resultSet.getColumnIndex("level"));
        list.push({
          id,
          keyname,
          status,
          level,
        })
      }
      resultSet.close()
    })
    return list
  }

  // 插入单挑数据
  insert(config: Config) {
    const valueBucket = {
      id: config?.id,
      keyname: config?.keyname || "",
      status: config?.status || "",
      level: config?.level || "",
    };

    this.store.insert(this.tableName, valueBucket, (err, rowId) => {
      if (err) {
        console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
        return;
      }
    })
  }

  // 批量添加
  batchInsert(configs?: Config[]) {
    if (configs == null) {
      return
    }
    if (configs != null && configs.length === 0) {
      return
    }
    if (configs != null && configs.length > 0) {
      this.store.batchInsert(this.tableName, configs as any, (err, rowId) => {
        if (err) {
          console.error(`Failed to bacth insert data. Code:${err.code}, message:${err.message}`);
          return;
        }
      })
    }
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