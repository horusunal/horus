#!/usr/bin/env python

# Written by 
# Sebastian Munera Alvarez and 
# Cesar Augusto Cartagena Ocampo 
# for the HORUS Project
# Universidad Nacional de Colombia
#   Copyright 2012 HORUS

import MySQLdb as mdb
import sys

# Synchronize a table between a local and a remote database
def sync_table(station, cur_local, cur_remote, tablename, pkattr, attr):    
    # Query to retrieve only primary keys
    pk_list = ''
    for i in range(len(pkattr)):
        pk_list += pkattr[i]
        if i < len(pkattr) - 1:
            pk_list += ','
        pk_list += ' '
    querypk = 'SELECT ' + pk_list + 'FROM ' + tablename + ' ORDER BY ' + pk_list
    
    # Query to retrieve all tuples from the table
    queryall = 'SELECT * FROM ' + tablename + ' ORDER BY ' + pk_list
	
	# Execute queries for local database
    cur_local.execute(queryall)
    data_local = cur_local.fetchall()
    cur_local.execute(querypk)
    pk_local = cur_local.fetchall()
    
    # Execute queries for remote database
    cur_remote.execute(queryall)
    data_remote = cur_remote.fetchall()
    cur_remote.execute(querypk)
    pk_remote = cur_remote.fetchall()
    
    # UPDATE DATA
    # Query for updating all attributes
    print 'Starting data updates on', tablename, '...'
    queryupdate = 'UPDATE ' + tablename + ' SET '
    for i in range(len(attr)):
        queryupdate += attr[i] + ' = %s'
        if i < len(attr) - 1:
            queryupdate += ','
        queryupdate += ' '
    queryupdate += 'WHERE '
    
    for i in range(len(pkattr)):
        queryupdate += pkattr[i] + ' = %s'
        if i < len(pkattr) - 1:
            queryupdate += ' AND '

    # If local primary key is included in the list of remote primary
    # keys, but if the complete local tuple is not in the list of remote
    # tuples, then some attribute changed
    prcntg_prev = -1
    for i in range(len(pk_local)):
        prcntg_cur = round((100.0 * (i + 1)) / len(pk_local))
        if prcntg_cur != prcntg_prev:
            print '   ', prcntg_cur, '%'
            prcntg_prev = prcntg_cur
        if pk_local[i] in pk_remote and data_local[i] not in data_remote:
            cur_remote.execute(queryupdate, data_local[i] + pk_local[i])
    print 'Ending data updates on', tablename
    print
    
    # INSERT NEW DATA
    # Query for inserting a tuple
    print 'Starting data insertions on', tablename, '...'
    queryinsert = 'INSERT INTO ' + tablename + ' VALUES (' + \
                   ('%s, ' * (len(attr) - 1)) + '%s)'

    # If local primary key is not included in the list of remote primary
    # keys, then this tuple does not exist in the remote database, so it
    # must be inserted
    prcntg_prev = -1
    for i in range(len(pk_local)):
        prcntg_cur = round((100.0 * (i + 1)) / len(pk_local))
        if prcntg_cur != prcntg_prev:
            print '   ', prcntg_cur, '%'
            prcntg_prev = prcntg_cur
        if pk_local[i] not in pk_remote:
            cur_remote.execute(queryinsert, data_local[i])
    print 'Ending data insertions on', tablename
    print

    # DELETE OUTDATED DATA
    # Query for deleting a tuple
    print 'Starting data deletions on', tablename, '...'
    querydelete = 'DELETE FROM ' + tablename + ' WHERE '
    for i in range(len(pkattr)):
        querydelete += pkattr[i] + ' = %s'
        if i < len(pkattr) - 1:
            querydelete += ' AND '

    # If remote primary key is not included in the list of local primary
    # keys, then this tuple has been deleted locally and must be deleted
    # remotely as well
    prcntg_prev = -1
    for i in range(len(pk_remote)):
        prcntg_cur = round((100.0 * (i + 1)) / len(pk_remote))
        if prcntg_cur != prcntg_prev:
            print '   ', prcntg_cur, '%'
            prcntg_prev = prcntg_cur
        if pk_remote[i] not in pk_local:
            cur_remote.execute(querydelete, pk_remote[i])
    print 'Ending data deletions on', tablename
    print
    
#-----------------------------------------------------------------------

def main(args):
    if len(args) != 12:
        print 'Usage:'
        print '   python sync_databases.py station hl ul pl dbl portl hr ur pr dbr portr'
        print
        print '   station: Station name'
        print '   hl: Local hostname or IP address'
        print '   ul: Local mysql username'
        print '   pl: Local mysql password'
        print '   dbl: Local mysql database name'
        print '   portl: Local mysql port'
        print '   hr: Remote hostname or IP address'
        print '   ur: Remote mysql username'
        print '   pr: Remote mysql password'
        print '   dbr: Remote mysql database name'
        print '   portr: Remote mysql port'
        return 1
		
    conn_local = None
    conn_remote = None
	
    try:
        station = args[1]
        host_local, user_local, pass_local, db_local, port_local = args[2:7]
        host_remote, user_remote, pass_remote, db_remote, port_remote = args[7:]
		
        conn_local = mdb.connect(host=host_local, user=user_local, passwd=pass_local, db=db_local, port=int(port_local))
        conn_remote = mdb.connect(host=host_remote, user=user_remote, passwd=pass_remote, db=db_remote, port=int(port_remote))
        cur_local = conn_local.cursor()
        cur_remote = conn_remote.cursor()
		
        sync_table(station, cur_local, cur_remote, 'ImageType' + '_' + station, ['idtype'], ['idtype', 'name', 'description'])
        sync_table(station, cur_local, cur_remote, 'Station', ['name'], ['name', 'alias', 'elevation', 'lat', 'lon', 'country', 'state', 'city', 'responsible', 'description'])
        sync_table(station, cur_local, cur_remote, 'GCP' + '_' + station, ['idgcp', 'station'], ['idgcp', 'station', 'name', 'x', 'y', 'z'])
        sync_table(station, cur_local, cur_remote, 'AutomaticParams' + '_' + station, ['idauto'], ['idauto', 'station', 'type', 'start_hour', 'start_minute', 'end_hour', 'end_minute', 'step', 'duration', 'num_images'])
        sync_table(station, cur_local, cur_remote, 'Image' + '_' + station, ['filename'], ['filename', 'type', 'timestamp', 'ismini', 'path'])
        sync_table(station, cur_local, cur_remote, 'Camera' + '_' + station, ['id', 'station'], ['id', 'station', 'reference', 'sizeX', 'sizeY'])
        sync_table(station, cur_local, cur_remote, 'ObliqueImage' + '_' + station, ['filename'], ['filename', 'camera', 'station'])
        sync_table(station, cur_local, cur_remote, 'Calibration' + '_' + station, ['idcalibration'], ['idcalibration', 'camera', 'station', 'timestamp', 'resolution', 'EMCuv', 'EMCxy', 'NCE'])
        sync_table(station, cur_local, cur_remote, 'PickedGCP' + '_' + station, ['calibration', 'gcp', 'station'], ['calibration', 'gcp', 'station', 'u', 'v'])
        sync_table(station, cur_local, cur_remote, 'ROI' + '_' + station, ['idroi'], ['idroi', 'idcalibration', 'type', 'timestamp'])
        sync_table(station, cur_local, cur_remote, 'ROICoordinate' + '_' + station, ['idroi', 'idcoord'], ['idroi', 'idcoord', 'u', 'v'])
        sync_table(station, cur_local, cur_remote, 'CalibrationParameter' + '_' + station, ['id'], ['id', 'calibration', 'name'])
        sync_table(station, cur_local, cur_remote, 'CalibrationValue' + '_' + station, ['idparam', 'idcol', 'idrow'], ['idparam', 'idcol', 'idrow', 'value'])
        sync_table(station, cur_local, cur_remote, 'TimeStack' + '_' + station, ['filename'], ['filename', 'camera', 'station', 'inittime', 'path', 'fps', 'numFrames'])
        sync_table(station, cur_local, cur_remote, 'Fusion' + '_' + station, ['id'], ['id', 'timestamp', 'type'])
        sync_table(station, cur_local, cur_remote, 'CameraByFusion' + '_' + station, ['idfusion', 'camera', 'station'], ['idfusion', 'camera', 'station', 'sequence'])
        sync_table(station, cur_local, cur_remote, 'FusionParameter' + '_' + station, ['id'], ['id', 'idfusion', 'name'])
        sync_table(station, cur_local, cur_remote, 'FusionValue' + '_' + station, ['idmatrix', 'idcol', 'idrow'], ['idmatrix', 'idcol', 'idrow', 'value'])
        sync_table(station, cur_local, cur_remote, 'CommonPoint' + '_' + station, ['idfusion', 'camera', 'station', 'name'], ['idfusion', 'camera', 'station', 'name', 'u', 'v'])
        sync_table(station, cur_local, cur_remote, 'MergedImage' + '_' + station, ['filename'], ['filename', 'idfusion'])
        sync_table(station, cur_local, cur_remote, 'Sensor' + '_' + station, ['name', 'station'], ['name', 'station', 'x', 'y', 'z', 'description'])
        sync_table(station, cur_local, cur_remote, 'MeasurementType' + '_' + station, ['id', 'station'], ['id', 'station', 'sensor', 'paramname', 'datatype', 'unitx', 'unity', 'unitz', 'axisnamex', 'axisnamey', 'axisnamez', 'description'])
        sync_table(station, cur_local, cur_remote, 'Measurement' + '_' + station, ['idmeasurement', 'station'], ['idmeasurement', 'station', 'type', 'timestamp'])
        sync_table(station, cur_local, cur_remote, 'MeasurementValue' + '_' + station, ['idmeasurement', 'station', 'idcol', 'idrow', 'iddepth'], ['idmeasurement', 'station', 'idcol', 'idrow', 'iddepth', 'value'])
        sync_table(station, cur_local, cur_remote, 'RectifiedImage' + '_' + station, ['filename'], ['filename', 'calibration'])

        conn_remote.commit()

    except mdb.Error, e:
        print 'Error %d: %s' % (e.args[0],e.args[1])
        return 1
    else:
        print 'Synchronization complete!'
        return 0
    finally:    
        if cur_local and conn_local:
            cur_local.close()
            conn_local.close()
        if cur_remote and conn_remote:
            cur_remote.close()
            conn_remote.close()
#-----------------------------------------------------------------------

if __name__ == '__main__':
	sys.exit(main(sys.argv))
