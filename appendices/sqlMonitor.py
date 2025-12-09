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
        self.min_total = float('inf')
        self.max_total = 0
        plt.rcParams['axes.xmargin'] = 0
        plt.rcParams['axes.ymargin'] = 0

    def update_xy_axis(self, results, frequency):
        self.ms += frequency
        self.x.append(self.ms)
        
        sorted_results = sorted(results, key=lambda x: x[1], reverse=True)
        
        if (len(self.y) == 0):
            self.y = [[] for x in range(len(sorted_results))]
        
        total_at_point = 0
        for i in range(len(sorted_results)):
            usage = float(sorted_results[i][1]) / 1024
            self.y[i].append(usage)
            total_at_point += usage
        
        if total_at_point < self.min_total:
            self.min_total = total_at_point
        if total_at_point > self.max_total:
            self.max_total = total_at_point
        
        if (len(self.x) > 50):
            self.x.pop(0)
            for i in range(len(self.y)):
                self.y[i].pop(0)

    def update_labels(self, results):
        total_mem = sum(map(lambda e: e[1], results))
        sorted_results = sorted(results, key=lambda x: x[1], reverse=True)
        self.mem_labels.clear()
        for i in range(len(sorted_results)):
            usage = float(sorted_results[i][1]) / 1024
            mem_type = sorted_results[i][0]
            mem_type = mem_type[7:]
            if (usage < total_mem / 1024 / 50):
                mem_type = '_' + mem_type
            label_with_usage = f"{mem_type} ({usage:.2f} KB)"
            self.mem_labels.append(label_with_usage)

    def draw_plot(self, plt, current_results):
        plt.clf()
        plt.stackplot(self.x, self.y, colors = self.color_sequence)
        plt.legend(labels=self.mem_labels, bbox_to_anchor=(1.04, 1), loc="upper left", borderaxespad=0)
        plt.xlabel("milliseconds since monitor began")
        plt.ylabel("Kilobytes of memory")
        
        title_text = "Memory Usage"
        if self.max_total > 0 and self.min_total < float('inf'):
            diff = self.max_total - self.min_total
            title_text += f" (Min-Max Difference: {diff:.2f} KB)"
        plt.title(title_text, fontsize=12, pad=10)

    def configure_plot(self, plt):
        plt.ion()
        fig = plt.figure(figsize=(14,5))
        plt.stackplot(self.x, self.y, colors=self.color_sequence)
        plt.legend(labels=self.mem_labels, bbox_to_anchor=(1.04, 1), loc="upper left", borderaxespad=0)
        plt.subplots_adjust(right=0.7)
        return fig

    def start_visualization(self, database_connection, connection_id, frequency):
        c = database_connection.cursor();
        fig = self.configure_plot(plt)
        while(True):
            c.execute(MEM_QUERY, (connection_id,))
            results = c.fetchall()
            self.update_xy_axis(results, frequency)
            self.update_labels(results)
            self.draw_plot(plt, results)
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
    database_connection.close()

if __name__ == "__main__":
    main()
