#!/usr/bin/env python3
"""Сборка отчёта ЛР №2.1 из запросов и скриншотов репозитория.

Запуск из корня репозитория: python tools/build_report.py
"""
from __future__ import annotations
import io
import urllib.request
import zipfile
from pathlib import Path
from PIL import Image, ImageOps, ImageDraw
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.shared import Cm, Pt, Inches, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'report' / 'ЛР2_ч1_КорнеевГИ_ИУ5-34Б.docx'
MEDIA = ROOT / 'screenshots' / 'queries'
LOGO = ROOT / 'assets' / 'bauman_logo.png'
GEN = ROOT / 'report' / '.generated_media'

TASKS = [
    ('Создать запрос, выбирающий все записи из некоторой таблицы (SELECT * FROM Table).',
     'Выведены все записи таблицы student. На момент первого выполнения в таблице находился один студент.', 'task_01_select_all.png'),
    ('Создать запрос, выбирающий данные из некоторых столбцов таблицы.',
     'Из таблицы student получены фамилия, имя и номер учебной группы.', 'task_02_select_columns.png'),
    ('Составить запрос с использованием сортировки данных (ORDER BY).',
     'Дисциплины упорядочены по названию по возрастанию (ASC). В исходной таблице на момент проверки была одна запись.', 'task_03_order_by.png'),
    ('Сформировать запрос с ограничением числа возвращаемых строк (LIMIT и OFFSET).',
     'Запрос возвращает не более одной записи после пропуска нуля строк (LIMIT 1 OFFSET 0).', 'task_04_limit_offset.png'),
    ('Составить запрос с ограничениями на значения полей (WHERE с операторами сравнения, BETWEEN).',
     'Выбраны курсы 3–5 семестров учебного года 2026/2027; получено 5 записей.', 'task_05_where_between.png'),
    ('Составить запрос с использованием оператора IN, содержащего подзапрос.',
     'По подзапросу к control_result выбраны три студента, имеющие оценку «5».', 'task_06_in_subquery.png'),
    ('Составить запрос с использованием оператора LIKE (например, поиск по шаблону).',
     'По шаблону «П%» найден студент, фамилия которого начинается с буквы «П».', 'task_07_like.png'),
    ('Составить запрос, выбирающий записи, где определённое поле равно NULL (IS NULL).',
     'Найден студент, у которого не заполнено отчество (patronymic IS NULL).', 'task_08_is_null.png'),
    ('Составить запрос с использованием агрегатных функций (COUNT, SUM, AVG, MIN, MAX).',
     'Вычислены количество курсов (5), сумма номеров семестров (19), среднее (3,8), минимум (3) и максимум (5).', 'task_09_aggregate.png'),
    ('Составить запрос с агрегатными функциями и условием HAVING для отсева групп.',
     'С помощью GROUP BY и HAVING найден семестр 3, в котором проводится более двух курсов (3 курса).', 'task_10_group_by_having.png'),
    ('Составить запрос, выбирающий данные из нескольких таблиц с использованием соединения (INNER JOIN или LEFT JOIN).',
     'Соединены таблицы student и study_group; получены 7 студентов с годами набора групп.', 'task_11_inner_join.png'),
    ('Составить запрос с использованием ключевого слова DISTINCT для выборки уникальных значений.',
     'Выведены три неповторяющихся номера учебных групп, в которых есть студенты.', 'task_12_distinct.png'),
    ('Составить запрос с использованием предиката EXISTS (подзапрос в условии).',
     'Найдены четыре преподавателя, для которых существует хотя бы один курс дисциплины.', 'task_13_exists.png'),
    ('Составить запрос с использованием выражения CASE для условного вывода.',
     'Девять результатов контроля условно разделены на «Успешно» и «Требует улучшения»; предусмотрен вариант «Нет оценки».', 'task_14_case.png'),
]
VARIANT = [
    ('Получить список объектов, для которых существует хотя бы одна связанная запись в другой таблице.',
     'С помощью EXISTS получен список семи студентов, у которых имеется хотя бы один результат контроля в таблице control_result.', 'variant_13_task_01_exists.png'),
    ('Определить категории, для которых отсутствуют связанные объекты.',
     'В качестве категорий выбраны учебные группы: запрос с NOT EXISTS нашёл группу ИУ5-99Б (год набора 2026), в которой нет студентов.', 'variant_13_task_02_not_exists.png'),
]

def ru_font(run, *, size=12, bold=False):
    run.font.name = 'Times New Roman'
    run.font.size = Pt(size)
    run.bold = bold
    run.font.color.rgb = RGBColor(0,0,0)
    rpr = run._element.get_or_add_rPr()
    rf = rpr.rFonts
    if rf is not None:
        rf.set(qn('w:eastAsia'), 'Times New Roman')
    return run

def add_text(par, text, *, size=12, bold=False):
    return ru_font(par.add_run(text), size=size, bold=bold)

def space(par, before=0, after=0, line=1.1):
    f = par.paragraph_format
    f.space_before = Pt(before)
    f.space_after = Pt(after)
    f.line_spacing = line

def add_bottom_border(par):
    pPr = par._p.get_or_add_pPr(); pbdr = OxmlElement('w:pBdr'); b=OxmlElement('w:bottom')
    for k,v in [('val','single'),('sz','18'),('space','1'),('color','000000')]:b.set(qn('w:'+k),v)
    pbdr.append(b);pPr.append(pbdr)

def download_logo():
    if LOGO.exists():return
    old = 'https://raw.githubusercontent.com/gregkorneev-BMSTU/Data-Models_Lab1.2/main/report/'
    name = 'ЛР1.2_КорнеевГИ_ИУ5-34Б.docx'
    from urllib.parse import quote
    try:
        with urllib.request.urlopen(old+quote(name),timeout=25) as r: b=r.read()
        with zipfile.ZipFile(io.BytesIO(b)) as z:
            logo=z.read('word/media/image1.png')
        LOGO.parent.mkdir(parents=True,exist_ok=True);LOGO.write_bytes(logo)
    except Exception as e:
        print('Не удалось загрузить логотип; титул будет без него:',e)

def compact_screenshot(filename):
    # Для первого скриншота устраняем пустое пространство SQL-редактора,
    # сохраняя исходные фрагменты запроса и результата без ретуширования.
    src=MEDIA/filename
    if filename!='task_01_select_all.png':return src
    GEN.mkdir(parents=True,exist_ok=True)
    dst=GEN/'task_01_compact.png'
    im=Image.open(src).convert('RGB')
    top=im.crop((320,75,1220,165))
    bottom=im.crop((320,548,1220,695))
    out=Image.new('RGB',(900,90+10+147),(30,32,36))
    out.paste(top,(0,0)); out.paste(bottom,(0,100))
    out.save(dst,optimize=True)
    return dst

def add_screenshot(doc, fname, idx, *, max_height=3.05):
    path=compact_screenshot(fname)
    assert path.exists(),path
    w,h=Image.open(path).size
    width=min(6.12,max_height*w/h)
    p=doc.add_paragraph(style='Normal')
    p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.keep_together=True
    space(p,before=4,after=2)
    p.add_run().add_picture(str(path), width=Inches(width))
    caption=doc.add_paragraph(style='Caption')
    caption.alignment=WD_ALIGN_PARAGRAPH.CENTER
    space(caption,before=1,after=5)
    add_text(caption,f'Рисунок {idx} — Результат выполнения запроса',size=10, bold=False)

def page_field(run):
    b=OxmlElement('w:fldChar');b.set(qn('w:fldCharType'),'begin')
    text=OxmlElement('w:instrText');text.set(qn('xml:space'),'preserve');text.text=' PAGE '
    s=OxmlElement('w:fldChar');s.set(qn('w:fldCharType'),'separate')
    t=OxmlElement('w:t');t.text='1'
    e=OxmlElement('w:fldChar');e.set(qn('w:fldCharType'),'end')
    for x in (b,text,s,t,e):run._r.append(x)

def build():
    download_logo()
    OUTPUT.parent.mkdir(parents=True,exist_ok=True)
    doc=Document()
    sec=doc.sections[0];sec.page_width=Cm(21);sec.page_height=Cm(29.7)
    sec.top_margin=Cm(1.8);sec.bottom_margin=Cm(1.8)
    sec.left_margin=Cm(3);sec.right_margin=Cm(1.5)
    sec.header_distance=Cm(0.8);sec.footer_distance=Cm(1.0)
    sec.different_first_page_header_footer=True
    st=doc.styles['Normal'];st.font.name='Times New Roman';st.font.size=Pt(12)
    st.paragraph_format.line_spacing=1.10;st.paragraph_format.space_after=Pt(3)
    cap=doc.styles['Caption'];cap.font.name='Times New Roman';cap.font.size=Pt(10)
    ftr=sec.footer.paragraphs[0];ftr.alignment=WD_ALIGN_PARAGRAPH.RIGHT
    page_field(ru_font(ftr.add_run(),size=10))
    # Титульный лист по образцу: герб, шапка, разделитель, факультет/кафедра,
    # заголовок и сведения об исполнителе.
    table=doc.add_table(rows=1, cols=2);table.autofit=False
    table.columns[0].width=Cm(2.4);table.columns[1].width=Cm(13.7)
    table.cell(0,0).vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
    if LOGO.exists():
        table.cell(0,0).paragraphs[0].add_run().add_picture(str(LOGO),width=Cm(2.4))
    p=table.cell(0,1).paragraphs[0];p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    space(p,after=0,line=1.07)
    add_text(p,'Министерство науки и высшего образования Российской Федерации\n',size=10.2,bold=True)
    add_text(p,'Федеральное государственное автономное образовательное учреждение\nвысшего образования\n',size=10.2,bold=True)
    add_text(p,'«Московский государственный технический университет\nимени Н. Э. Баумана\n(национальный исследовательский университет)»\n',size=10.2,bold=True)
    add_text(p,'(МГТУ им. Н. Э. Баумана)',size=10.2,bold=True)
    line=doc.add_paragraph();space(line,before=6,after=10);add_bottom_border(line)
    for lab,val in [('ФАКУЛЬТЕТ','ИНФОРМАТИКА И СИСТЕМЫ УПРАВЛЕНИЯ'),('КАФЕДРА','СИСТЕМЫ ОБРАБОТКИ ИНФОРМАЦИИ И УПРАВЛЕНИЯ')]:
        p=doc.add_paragraph();space(p,after=2)
        add_text(p,lab+'    ',size=11);add_text(p,val,size=11)
    p=doc.add_paragraph();space(p,before=110,after=8)
    p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    add_text(p,'Лабораторная работа №2 (часть 1)',size=15,bold=True)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;space(p,after=5)
    add_text(p,'Дисциплина: Модели данных',size=14,bold=True)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;space(p,after=0)
    add_text(p,'«SELECT-запросы с сортировкой и ограничениями»',size=13.5,bold=True)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.RIGHT;space(p,before=105,after=2)
    add_text(p,'Выполнил: Корнеев Григорий,',size=12)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.RIGHT;space(p,after=0)
    add_text(p,'студент группы ИУ5-34Б',size=12)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;space(p,before=125)
    add_text(p,'2026 г.',size=12)
    doc.add_page_break()
    # Общая часть — структурно как в образце: точная формулировка, результат в DBeaver, пояснение.
    for i,(prompt,meaning,shot) in enumerate(TASKS,1):
        p=doc.add_paragraph();p.paragraph_format.keep_with_next=True
        space(p,before=8,after=5)
        add_text(p,f'{i}.  {prompt}',size=12,bold=True)
        add_screenshot(doc,shot,i,max_height=2.85 if i not in (11,14) else 3.55)
        p=doc.add_paragraph();space(p,after=9,line=1.1)
        add_text(p,meaning,size=11.2)
    # Индивидуальная часть — вариант пользователя, НЕ вариант 21 из шаблона.
    h=doc.add_paragraph();h.paragraph_format.keep_with_next=True;space(h,before=14,after=6)
    add_text(h,'Задания по варианту №13',size=14,bold=True)
    for j,(prompt,meaning,shot) in enumerate(VARIANT,1):
        p=doc.add_paragraph();p.paragraph_format.keep_with_next=True;space(p,before=8,after=5)
        add_text(p,f'{j}.  {prompt}',size=12,bold=True)
        add_screenshot(doc,shot,14+j,max_height=3.6)
        p=doc.add_paragraph();space(p,after=9)
        add_text(p,meaning,size=11.2)
    p=doc.add_paragraph();p.paragraph_format.keep_with_next=True;space(p,before=13,after=6)
    add_text(p,'Вывод',size=14,bold=True)
    for text in [
        'В ходе лабораторной работы изучены возможности языка SQL для выборки и обработки данных в СУБД SQLite с использованием среды DBeaver. Работа выполнена на базе данных учебного процесса кафедры ИУ5, разработанной в ЛР №1 (часть 2) и дополненной тестовыми записями.',
        'Выполнены 14 общих заданий: запросы SELECT, сортировка ORDER BY, ограничения LIMIT и OFFSET, фильтрация WHERE, BETWEEN, IN, LIKE и IS NULL, агрегатные функции COUNT, SUM, AVG, MIN, MAX, группировка GROUP BY и HAVING, INNER JOIN, DISTINCT, EXISTS и CASE.',
        'В индивидуальной части по варианту №13 составлены запросы для поиска студентов, имеющих связанные результаты контроля, и учебных групп, не содержащих студентов. Всего выполнено и проверено 16 SQL-запросов; результаты подтверждены скриншотами из DBeaver.'
    ]:
        p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.JUSTIFY;space(p,after=8,line=1.18)
        p.paragraph_format.first_line_indent=Cm(1.0)
        add_text(p,text,size=12)
    doc.core_properties.author='Корнеев Григорий'
    doc.core_properties.title='ЛР №2 (часть 1) — SELECT-запросы с сортировкой и ограничениями'
    doc.core_properties.subject='Модели данных, вариант 13, кафедра ИУ5'
    doc.save(OUTPUT)
    print('Отчёт:',OUTPUT,'байт:',OUTPUT.stat().st_size)

if __name__=='__main__':build()