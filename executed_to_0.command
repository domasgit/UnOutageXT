#!/usr/bin/env python3

import sqlite3, os, csv
import sys


dir_path = os.path.dirname(os.path.realpath(__file__))
print(f"working in folder {dir_path}....")
con = None

unsent_payment_pattern = "(amount > 0 AND transaction_processdata IS NULL AND type_id = 2 AND processor_accepted = 0)"

def load_fp_invoicenos():
    with open('foobar.csv') as file:
        reader = csv.reader(file)
        fp_invoice_numbers = [row[7] for row in reader]

    return fp_invoice_numbers[1::]

def load_db_invoicenos(cur):
    db_invoicenos = [x[0] for x in cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()]
    return db_invoicenos

def compare_invoicenos(db_invoicenos, fp_invoicenos):
    unsent_invoicenos = [invoiceno for invoiceno in db_invoicenos if invoiceno not in fp_invoicenos]
    return unsent_invoicenos

def check_unsent_orders(cur, missing_invoicenos):
    ids = [x[0] for x in cur.execute(f"SELECT order_id FROM payment WHERE transaction_invoiceno IN ({','.join(missing_invoicenos)})").fetchall()]
    #print(ids)
    unsent_ordernos = [x[0] for x in cur.execute(f"SELECT res_id FROM purchase_order WHERE id IN ({','.join(map(str, ids))})").fetchall()]
    return unsent_ordernos

def main():
    try:
        #initiate DB and cursor
        con = sqlite3.connect(dir_path+'/db.sqlite')
        cur = con.cursor()
        db_invoicenos = load_db_invoicenos(cur)
        #print(f"db invoicenos:{db_invoicenos}")
        if len(db_invoicenos) == 0:
            print("No unsent payments found in DB")
            return
        fp_invoicenos = load_fp_invoicenos()
        #print(f"fp invoicenos:{fp_invoicenos}")
        missing_invoicenos = compare_invoicenos(db_invoicenos, fp_invoicenos)
        #print(f"missing invoicenos:{missing_invoicenos}")
        unsent_ordernos = check_unsent_orders(cur, missing_invoicenos)

        if len(unsent_ordernos) == 0:
            print("No payments missing from FP")
            return

        print(f"{len(unsent_ordernos)} orders have not been found in FP report. Order numbers:\n")
        print(unsent_ordernos)
        

#        invoicenos = cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()
#        db_invoicenos = [x[0] for x in cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()]
#        print(db_invoicenos)

#        unsent_invoicenos = [invoiceno for invoiceno in db_invoicenos if invoiceno not in fp_invoicenos]
#        print(unsent_invoicenos)

        #check for unsent orders and mark sent
        cur.execute("UPDATE purchase_order SET status = 2 WHERE status = 0")

        #run executed fixer
        #cur.execute(f"UPDATE payment SET executed = 0 WHERE transaction_invoiceno IN ({','.join(unsent_invoicenos)})")
        con.commit()
        con.close()

    except sqlite3.Error as e:
        print(f"Error {e.args[0]}")
        return
        
#    finally:
#        os.rename(dir_path+"/db.sqlite",dir_path+"/pos2v.sqlite")


if __name__ == "__main__":
    main()

#credits(c) Dominykas Jasiulionis, Pasha also helped and Vikce finished it up