#!/usr/bin/env python3

# Script source: https://planetscale.com/blog/profiling-memory-usage-in-mysql#plotting-memory-usage

import matplotlib.pyplot as plt
import numpy as np
import pymysql
pymysql.install_as_MySQLdb()
import MySQLdb
import argparse

MEM_QUERY='''
SELECT event_name, current_number_of_bytes_used
  FROM performance_schema.memory_summary_by_thread_by_event_name
  WHERE thread_id = %s
  ORDER BY event_name DESC'''

TID_QUERY='''
SELECT  thread_id
  FROM performance_schema.threads
  WHERE PROCESSLIST_ID=%s'''

class MemoryProfiler:

    def __init__(self):
        self.x = []
        self.y = []
        self.mem_labels = ['XXXXXXXXXXXXXXXXXXXXXXX']
        self.ms = 0
        self.color_sequence = ['#ffc59b', '#d4c9fe', '#a9dffe', '#a9ecb8',
                               '#fff1a8', '#fbbfc7', '#fd812d', '#a18bf5',
                               '#47b7f8', '#40d763', '#f2b600', '#ff7082']
        plt.rcParams['axes.xmargin'] = 0
        plt.rcParams['axes.ymargin'] = 0
        plt.rcParams["font.family"] = "inter"

    def update_xy_axis(self, results, frequency):
        self.ms += frequency
        self.x.append(self.ms)
        if (len(self.y) == 0):
            self.y = [[] for x in range(len(results))]
        for i in range(len(results)-1, -1, -1):
            usage = float(results[i][1]) / 1024
            self.y[i].append(usage)
        if (len(self.x) > 50):
            self.x.pop(0)
            for i in range(len(self.y)):
                self.y[i].pop(0)

    def update_labels(self, results):
        total_mem = sum(map(lambda e: e[1], results))
        self.mem_labels.clear()
        for i in range(len(results)-1, -1, -1):
            usage = float(results[i][1]) / 1024
            mem_type = results[i][0]
            # Remove 'memory/' from beginning of name for brevity
            mem_type = mem_type[7:]
            # Only show top memory users in legend
            if (usage < total_mem / 1024 / 50):
                mem_type = '_' + mem_type
            self.mem_labels.insert(0, mem_type)

    def draw_plot(self, plt):
        plt.clf()
        plt.stackplot(self.x, self.y, colors = self.color_sequence)
        plt.legend(labels=self.mem_labels, bbox_to_anchor=(1.04, 1), loc="upper left", borderaxespad=0)
        plt.xlabel("milliseconds since monitor began")
        plt.ylabel("Kilobytes of memory")

    def configure_plot(self, plt):
        plt.ion()
        fig = plt.figure(figsize=(12,5))
        plt.stackplot(self.x, self.y, colors=self.color_sequence)
        plt.legend(labels=self.mem_labels, bbox_to_anchor=(1.04, 1), loc="upper left", borderaxespad=0)
        plt.tight_layout(pad=4)
        return fig

    def start_visualization(self, database_connection, connection_id, frequency):
        c = database_connection.cursor();
        fig = self.configure_plot(plt)
        while(True):
            c.execute(MEM_QUERY, (connection_id,))
            results = c.fetchall()
            self.update_xy_axis(results, frequency)
            self.update_labels(results)
            self.draw_plot(plt)
            fig.canvas.draw_idle()
            fig.canvas.start_event_loop(frequency / 1000)

def get_command_line_args():
    '''
    Process arguments and return argparse object to caller.
    '''
    parser = argparse.ArgumentParser(description='Monitor MySQL query memory for a particular connection.')
    parser.add_argument('--connection-id', type=int, required=True,
                        help='The MySQL connection to monitor memory usage of')
    parser.add_argument('--frequency', type=float, default=500,
                        help='The frequency at which to ping for memory usage update in milliseconds')
    return parser.parse_args()

def get_thread_for_connection_id(database_connection, cid):
    '''
    Get a thread ID corresponding to the connection ID
    PARAMS
      database_connection - Database connection object
      cid - The connection ID to find the thread for
    '''
    c = database_connection.cursor()
    c.execute(TID_QUERY, (cid,))
    result = c.fetchone()
    return int(result[0])

def main():
    args = get_command_line_args()
    database_connection = MySQLdb.connect(host='127.0.0.1', user='root', password='1234')
    connection_id = get_thread_for_connection_id(database_connection, args.connection_id)
    m = MemoryProfiler()
    m.start_visualization(database_connection, connection_id, args.frequency)
    connection.close()

if __name__ == "__main__":
    main()