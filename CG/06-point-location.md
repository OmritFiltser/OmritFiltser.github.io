# מיקום נקודה ומפה טרפזית {#point-location}

## הקדמה {#preface-6}

### מה ביחידה? {#contents-6}

#### מיקום נקודה ומפה טרפזית {.unnumbered}
יחידה זו מקבילה לפרק השישי בספר הלימוד. 

בסיום יחידה זו, תכירו את המושגים ותרכשו את הטכניקות והכלים הבאים:

- בעיית מיקום נקודה במפה מישורית.
- מפה טרפזית.
- אלגוריתם אינקרמנטלי-רנדומי לבניית מבנה נתונים עבור שאילתות מיקום נקודה.

למידה מהנה!

### מיקום נקודה במפה {#point-on-map}

<img src="images/6/us-map.png" align="left" width="50%"/> מפה המתארת חלוקה למדינות, כמו מפת ארצות הברית המופיעה משמאל, היא בעצם גרף מישורי המתואר באמצעות צלעות, פאות וקודקודים. כל מדינה או אזור במפה מתאימים לפאה של הגרף. ביחידה הזו נעסוק בבעיה הבסיסית הבאה: בהינתן הקואורדינטות של נקודה כלשהי על המפה, לאיזו מדינה שייכת הנקודה?

#### קראו את ההקדמה לפרק 6 בספר הלימוד (עמודים 121--122). {.unnumbered}

------------------------------------------------------------------------

## מפה טרפזית {#trapezoidal-map}

### פתרון נאיבי: חלוקה לרצועות {#naive-sol}

תהי $\mathcal{S}$ מפה מישורית, כפי שהגדרנו ביחידה 2: $\mathcal{S}$ היא שיכון של גרף מישורי במישור, כך שכל הצלעות שלו הן קטעים ישרים. נרצה לבנות מבנה נתונים שיענה על שאילתות מהסוג הבא: בהינתן נקודה $q$ במישור, מצא את הפאה שבה $q$ נמצאת.

<img src="images/6/slabs.jpg" align="left" width="40%"/> שימו לב שכדי למצוא את הפאה שבה $q$ נמצאת, מספיק לבדוק למשל איזו צלע של $\mathcal{S}$ הנקודה $q$ "רואה" מעליה. לכן בחלק הראשון של סעיף 6.1 בספר הלימוד מתואר פתרון נאיבי ופשוט לבעיה, על ידי חלוקה של המפה לרצועות (slabs): נעביר ישר אנכי דרך כל אחד מהקודקודים של $\mathcal{S}$. האזור שנמצא בין שני ישרים עוקבים כאלו הוא רצועה אנכית. בהינתן שמספר הקודקודים במפה $\mathcal{S}$ הוא n, ניתן למצוא את הרצועה שבה נמצאת נקודה נתונה $q$ בזמן $O (\log n )$ על ידי חיפוש בינארי. כל רצועה "נחתכת" על ידי לכל היותר $n$ צלעות של $\mathcal{S}$. הצלעות כמובן אינן חותכות זו את זו, ואין קודקודים של $\mathcal{S}$ בתוך הרצועה. לכן נוכל לשמור את רשימת הצלעות האלו בסדר ממוין, ואז למצוא את הצלע שהנקודה $q$ "רואה" מעליה על ידי חיפוש בינארי, כלומר שוב $O (\log n )$.

בדרך זו, זמן השאילתה שנקבל הוא $O (\log n )$. אך מהו גודל המבנה וזמן העיבוד המקדים? באיור למטה ניתן לראות דוגמה למקרה שבו גודל המבנה הוא $\Theta ( n^2 )$ (מדוע?).

<center>![](images/6/slabs_n_squared.jpg){width="60%"}</center>

#### קראו את חלקו הראשון של סעיף 6.1 בספר הלימוד (עמודים 122--124). {.unnumbered}

### פירוק לטרפזים

שימו לב שהחלוקה לרצועות שראינו בעמוד הקודם יוצרת מפה מישורית $\mathcal{S'}$ שבה כל פאה היא טרפז או משולש (או פאה אינסופית דמוית טרפז/משולש). המפה $\mathcal{S'}$ היא עידון (refinement) של המפה המקורית $\mathcal{S}$, כלומר כל פאה של $\mathcal{S'}$ מוכלת לחלוטין בפאה של $\mathcal{S}$, ולכן אם מצאנו שנקודת השאילתה נמצאת בפאה מסוימת של $\mathcal{S'}$, נוכל לדעת לאיזו פאה של $\mathcal{S}$ היא שייכת. העידון בעזרת חלוקה לרצועות מוביל למבנה נתונים בגודל ריבועי (במקרה הגרוע), ולכן אינו מעשי. בחלק זה נראה עידון אחר שסיבוכיות הזיכרון שלו לא תהיה גדולה בהרבה מזו של $\mathcal{S}$, ושעדיין יאפשר לנו לענות על שאילתות מיקום נקודה בקלות יחסית.

#### צפו בסרטון הבא: {.unnumbered}

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/Gx2veCtl7Fc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>

</iframe></center>

#### ענו על השאלה הבאה: {.unnumbered}
מי ה-$leftp$ של כל אחד מהטרפזים המסומנים באיור?

<center>![](images/6/leftp_question.jpg){width="80%"}</center>

<details>

<summary>(פתרון)</summary>

(TODO)

<center>![](images/6/leftp_question.jpg){width="80%"}</center>

</details>


#### להרחבה ולהעשרה: הנחת מצב כללי {.unnumbered}

בשיטת הפירוק לטרפזים אנחנו מניחים שבאוסף הקטעים הנתון אין שתי נקודות קצה בעלות אותה קואורדינטת $x$. הנחה זו אינה ריאלית, אך כפי שכבר ראינו בעבר, קיימות מספר שיטות המאפשרות לנו לטפל במצב לא כללי -- למשל סיבוב המישור או קביעת סדר לקסיקוגרפי. הדיון בפתרונות אלו עבור המבנה של מפת טרפזים מופיע בסעיף 6.3 בספר הלימוד.

#### ענו על השאלה הבאה: {.unnumbered}
במצב לא כללי, כמה טרפזים שכנים יש לכל היותר לטרפז במפה הטרפזית?

<details>

<summary>(פתרון)</summary>

<img src="images/6/not_general_pos.jpg" align="left" width="30%"/>במצב לא כללי, יתכן למשל שיהיו $\Theta(n)$ נקודות קצה ימניות של קטעים שכולן עם אותה קואורדינטת x, וכולן על אותה צלע אנכית, כמו באיור משמאל. במצב זה, כל הטרפזים הצהובים הם שכנים של הטרפז Δ.

<br/>
<br/>
<br/>
<br/>


</details>


#### לחזרה: קראו את חלקו השני של סעיף 6.1 בספר הלימוד (עמודים 124--128). {.unnumbered}

------------------------------------------------------------------------

## שאילתות מיקום נקודה {#point-location-queries}

### מבנה נתונים לשאילתות מיקום נקודה {#the-data-structure}

יהי $\mathcal{S}$ אוסף של $n$ קטעים במצב כללי שאינם נחתכים.

ניתן לבנות את המפה הטרפזית $\mathcal{T}(\mathcal{S})$ בקלות יחסית על ידי שימוש בשיטת הישר הסורק (חשבו כיצד). הבעיה היא שבשיטה זו לא נוכל לבנות מבנה נתונים התומך בשאילתות מיקום נקודה, שהוא המטרה המרכזית שלנו ביחידה זו. איך ייראה מבנה נתונים כזה?

בחלק זה נתאר את מבנה החיפוש $\mathcal{D}$ שיאפשר לנו לבצע שאילתות מיקום נקודה במפה הטרפזית $\mathcal{D}$. בהמשך היחידה נראה אלגוריתם אינקרמטלי-רנדומי שבונה את המפה הטרפזית $\mathcal{T}(\mathcal{S})$ ואת מבנה הנתונים $\mathcal{D}$ גם יחד.

#### תיאור מבנה הנתונים {.unnumbered}

מבנה הנתונים $\mathcal{D}$ יהיה גרף מכוון חסר מעגלים (DAG), שבו שלושה סוגי צמתים:

-   צומת (פנימי) x -- מתאים לנקודת קצה של קטע מ-$\mathcal{S}$ (מסומן בעיגול לבן).
-   צומת (פנימי) y -- מתאים לקטע מ-$\mathcal{S}$ (מסומן בעיגול אפור).
-   עלה -- מתאים לטרפז במפה $\mathcal{T}(\mathcal{S})$ (מסומן בריבוע).

נוסף על כך, לגרף יש שורש יחיד ובדיוק עלה אחד לכל טרפז במפה $\mathcal{T}(\mathcal{S})$. למשל באיור למטה, לעלה של טרפז C יש מצביעים משני קודקודים פנימיים.

הרעיון בבנייה זו דומה לעצי kd שראינו ביחידה 5: לכל צומת פנימי, ההסתעפות ימינה או שמאלה תלויה בתשובה לשאלה המתאימה לסוג הצומת.

<center>![](images/6/ds.jpg){width="100%"}</center>


#### אלגוריתם השאילתה {.unnumbered}

בהינתן נקודת שאילתה q, נתחיל את החיפוש מהשורש עד שנגיע לעלה:

-   אם הגענו לצומת $x$ המתאים לנקודת קצה $p$, נשאל: "האם $q$ מימין או משמאל לישר האנכי שעובר דרך p?". אם התשובה היא "מימין" -- נמשיך ימינה, אחרת שמאלה.
-   אם הגענו לצומת $y$ המתאים לקטע $s$, נשאל: "האם $q$ מעל או מתחת לקטע $s$?". אם התשובה היא "מתחת" -- נמשיך ימינה, אחרת שמאלה. שימו לב שכדי שהשאלה הזו תהיה הגיונית, נצטרך להבטיח שבשלב זה הישר האנכי שעובר דרך $q$ חותך את $s$.

כשנגיע לעלה, נבדוק אם הטרפז המתאים לו מכיל את $q$.

#### ענו על השאלה הבאה: {.unnumbered}
נתון מבנה החיפוש למטה.

<center>![](images/6/point_search_question.jpg){width="70%"}</center>

ידוע שנקודת שאילתה נמצאת:

-   מימין לישר האנכי העובר בנקודה $p_1$.
-   משמאל לישר האנכי העובר בנקודה $q_1$.
-   מתחת לקטע $s_1$.

באילו מהטרפזים ייתכן שהנקודה נמצאת?

אם בנוסף ידוע שהנקודה נמצאת:

-   משמאל לישר האנכי העובר בנקודה $q_2$.
-   מעל לקטע $s_2$.

באילו מהטרפזים ייתכן שהנקודה נמצאת?

<details>

<summary>(פתרון)</summary>

TODO

</details>


### אלגוריתם אינקרמנטלי-רנדומי {#rand-inc-alg}

בחלק זה נתאר אלגוריתם אינקרמנטלי לבניית מבנה החיפוש $\mathcal{D}$ והמפה הטרפזית $\mathcal{T}(\mathcal{S})$ גם יחד. האלגוריתם מוסיף את הקטעים מהאוסף $\mathcal{S}$, זה אחר זה בסדר רנדומי, ובכל פעם מעדכן את מבנה החיפוש והמפה בהתאם לקטע החדש שנוסף.

הסיבה לכך שנבחר סדר רנדומי על הקטעים היא שבאופן זה נוכל לצפות לזמני ריצה ולסיבוכיות מקום יעילים, בדומה לאלגוריתם האינקרמנטלי-רנדומי לתכנון לינארי במישור שראינו ביחידה 4. נדון בכך בעמוד הבא של חלק זה.

#### צפו בסרטון הבא: {.unnumbered}

<center>

<iframe width="560" height="315" src="https://www.youtube.com/embed/Y5snemax_Ak" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>

</iframe>

</center>

#### קראו את חלקו הראשון של סעיף 6.2 בספר הלימוד (עמודים 128--133). {.unnumbered}
(עד הפסקה הראשונה בעמוד 133.)

#### ענו על השאלות הבאות: {.unnumbered}

**שאלה 1**:
התבוננו באיור הבא:

<center>![](images/6/alg_question1.jpg){width="100%"}</center>

אילו טרפזים האלגוריתם ימצא ויעדכן כאשר נוסיף את $s_i$?

<details>

<summary>(פתרון)</summary>

<center>![](images/6/alg_question1-ans.jpg){width="100%"}</center>

</details>
<br/>

**שאלה 2**:
התבוננו באיור הבא, והשלימו את מבנה החיפוש.

<center>![](images/6/alg_question2.jpg){width="100%"}</center>

<details>

<summary>(פתרון)</summary>

<center>![](images/6/alg_question2_ans.jpg){width="100%"}</center>

</details>


### ניתוח האלגוריתם {#alg-analysis}

הסדר שבו האלגוריתם TrapezoidalMap מוסיף את הקטעים משפיע מאוד על גודל מבנה החיפוש $\mathcal{D}$ ועל זמן השאילתה. למעשה, ייתכן סדר שבו האלגוריתם ירוץ בזמן ריבועי, סיבוכיות הזיכרון של $\mathcal{D}$ תהיה ריבועית, וזמן השאילתה יהיה לינארי. לכן, בדומה לאלגוריתם האינקרמנטלי-רנדומי לתכנון לינארי במישור שראינו ביחידה 4, גם כאן האלגוריתם מגריל את סדר הוספת הקטעים מראש, ונוכל להראות שבתוחלת יתקבל מבנה חיפוש עם סיבוכיות זיכרון לינארית, ותוחלת זמן השאילתה תהיה $O (\log n )$.

#### תרגיל: מהו המקרה הגרוע ביותר? {.unnumbered}
נסו לתאר דוגמה לאוסף של $n$ קטעים ושל הסדר שלהם, כך שהאלגוריתם האינקרמנטלי (הלא רנדומי) ירוץ בזמן $O ( n^2 )$.

#### רעיון ההוכחה עבור זמן השאילתה {.unnumbered}

תהי $q$ נקודת שאילתה. נרצה להעריך את תוחלת אורך המסלול שבו נלך כאשר נחפש במבנה $\mathcal{D}$ את הטרפז שמכיל את $q$ (מספר הצמתים מהשורש לטרפז). לשם כך, ננסה להבין כיצד המסלול משתנה במהלך ריצת אלגוריתם הבנייה של $\mathcal{D}$.

למשל, ניתן להראות שבכל פעם שקטע חדש נוסף למבנה, המסלול יתארך לכל היותר בשלושה צמתים. לפיכך ניתן לומר שאורך המסלול הוא לכל היותר $3n$. זהו חסם עבור המקרה הגרוע, אך אנו מעוניינים במקרה הממוצע (על פני כל $n!$ הסדרים האפשריים), ולכן ננסה לחשב את ממוצע מספר הצמתים שנוספו למסלול בכל איטרציה של האלגוריתם.

נסמן ב-$X_i$ (עבור $1 \le i \le n$) את מספר הצמתים על המסלול שנוספו באיטרציה ה-$i$-ית (כלומר לאחר הוספת הקטע $s_i$). לפיכך, $X_i$ הוא משתנה מקרי התלוי בסדר הוספת הקטעים, ולכן תוחלת אורך המסלול אל הטרפז המכיל את $q$ היא $E[ \sum_{i=1}^{n} X_i ]$, ומלינאריות התוחלת $\sum_{i=1}^{n} E[X_i]$.

מכיוון שבכל איטרציה נוספים לכל היותר שלושה צמתים למסלול, מתקיים $X_i \le 3$. לכן, אם נסמן ב-$P_i$ את ההסתברות לכך שקיים צומת במסלול שנוצר באיטרציה ה-$i$-ית, נקבל $E[ X_i ] \le 3 P_i$.

האבחנה המרכזית בהוכחה היא שבאיטרציה ה-$i$-ית נוסף קודקוד למסלול שלנו רק אם הטרפז שמכיל את $q$ בדיוק לפני הוספת $s_i$ שונה מהטרפז המכיל את $q$ מייד לאחר הוספת $s_i$. לכן, בדומה להוכחה שראינו ביחידה 4, נוכל לנתח את ההסתברות לכך שהטרפז המכיל את $q$ משתנה בין האיטרציה ה-$i – 1$ לאיטרציה ה-$i$-ית בשיטת הניתוח לאחור (backwards analysis). כלומר, נסתכל על המפה שהתקבלה מייד לאחר הוספת $s_i$, ונשאל מה ההסתברות לכך שהטרפז $\Delta$ המכיל את $q$ במפה זו ייעלם אם נוציא את $s_i$. שימו לב שהטרפז $\Delta$ ייעלם אם ורק אם אחד מהשדות המגדירים אותו ($top(\Delta)$, $bottom(\Delta)$, $leftp(\Delta)$, $rightp(\Delta)$) ייעלם. ההסתברות לכך ש-$s_i$ הוא הקטע שמגדיר את $top(\Delta)$ למשל, היא $\frac{1}{i}$, ובאופן דומה ניתן לחשב זאת עבור $bottom(\Delta)$, $leftp(\Delta)$, $rightp(\Delta)$. לכן נקבל $P_i \le \frac{4}{i}$, ונוכל לחשב שתוחלת אורך המסלול היא $O (\log n )$.

#### קראו את חלקו השני של סעיף 6.2 בספר הלימוד (עמודים 133--137). {.unnumbered}
