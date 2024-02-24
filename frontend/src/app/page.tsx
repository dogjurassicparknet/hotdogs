"use client";
import Image from "next/image";
import styles from "./page.module.css";
import React from "react";

import { Quotes } from "../components/Quotes";

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.center}>
        <div>
          <Image
            className={styles.logo}
            src="/cohere.svg"
            alt="Cohere Logo"
            width={800}
            height={133}
            priority
          />
        </div>
      </div>
      <Quotes />
    </main>
  );
}
