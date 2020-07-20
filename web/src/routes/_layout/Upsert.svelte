<script context="module">
  export function prepareLookupLinks(key) {
    return [
      { site: 'iCIBA', href: `https://www.iciba.com/${key}` },
      {
        site: 'GTrans',
        href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${key}`,
      },
      {
        site: 'Google',
        href: `https://www.google.com/search?q=${key}`,
      },
      {
        site: 'Fanyi',
        href: `https://fanyi.baidu.com/#zh/en/${key}`,
      },
      {
        site: 'Baike',
        href: `https://baike.baidu.com/item/${key}`,
      },

      {
        site: 'Baidu',
        href: `http://www.baidu.com/s?wd=${key}`,
      },
    ]
  }
</script>

<script>
  import { onMount } from 'svelte'
  import relative_time from '$utils/relative_time'

  const tabs = [
    ['special', 'Riêng'],
    ['generic', 'Chung'],
  ]

  export let active = true

  export let key = ''
  export let dic = ''
  export let tab = 'special'

  export let shouldReload = false

  let keyField
  let valField

  let oldValue = ''
  let outValue = ''

  let isNewEntry = false

  $: if (key) searchWord(key, dic)
  $: links = prepareLookupLinks(key)

  $: mtime = props[tab].mtime
  $: suggests = makeSuggests(tab, outValue, oldValue)

  function makeSuggests(tab, reject, accept) {
    let output = []

    output = output.concat(props.suggest.vals)
    output = output.concat(props.special.vals)
    output = output.concat(props.generic.vals)

    let hanviet = props.hanviet
    if (tab === 'special') hanviet = titleize(hanviet, 9)
    output.push(hanviet)

    if (accept) output.push(accept)
    return output.filter((v, i, s) => s.indexOf(v) === i && v !== reject)
  }

  let props = {
    hanviet: '',
    binh_am: '',
    suggest: { vals: [], extra: '' },
    generic: { vals: [], mtime: 0, extra: '' },
    special: { vals: [], mtime: 0, extra: '' },
  }

  onMount(() => {
    if (key == '') keyField.focus()
    else refocusOnValField()
  })

  function changeTab(new_tab) {
    tab = new_tab
    updateVal()
    refocusOnValField()
  }

  function refocusOnValField() {
    if (valField) valField.focus()
  }

  function updateVal() {
    outValue = defaultVal(tab)

    if (outValue) {
      isNewEntry = false
    } else {
      isNewEntry = true
      let newValue = props.suggest.vals[0]

      if (!newValue) {
        newValue = props.hanviet
        if (tab === 'special') newValue = titleize(newValue, 9)
      }

      suggests = makeSuggests(tab, newValue, oldValue)

      if (suggests.length > 0) outValue = suggests[0]
      else outValue = newValue
    }
  }

  function defaultVal(tab) {
    return props[tab].vals[0]
  }

  function replaceValue(newValue) {
    oldValue = outValue
    outValue = newValue
    refocusOnValField()
  }

  async function upsertData(val) {
    let target = 'generic'
    if (tab === 'special') target = dic === '' ? 'combine' : dic

    const url = `/_upsert?dname=${target}&key=${key}&vals=${val}`
    const res = await fetch(url)

    if (defaultVal(tab) !== val) shouldReload = true
    active = false
  }

  async function searchWord(input, dname) {
    const res = await fetch(`/_search?input=${input}&dname=${dname}`)
    props = await res.json()
    updateVal()
  }

  function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1)
  }

  function titleize(input, count = 99) {
    const arr = input.split(' ')
    if (count > arr.length) count = arr.length

    for (let i = 0; i < count; i++) arr[i] = capitalize(arr[i])
    for (let i = count; i < arr.length; i++) arr[i] = arr[i].toLowerCase()

    return arr.join(' ')
  }

  function updateCase(count = 100) {
    outValue = titleize(outValue, count)
    refocusOnValField()
  }

  function submitOnEnter(evt) {
    if (evt.keyCode == 13 && !evt.shiftKey) {
      evt.preventDefault()
      return upsertData(outValue)
    }
  }

  function handleKeypress(evt) {
    if (evt.keyCode === 27) {
      evt.preventDefault()
      active = false
      return
    }

    if (!evt.altKey) return
    evt.preventDefault()

    switch (evt.keyCode) {
      case 49:
        updateCase(1)
        break

      case 50:
        updateCase(2)
        break

      case 51:
        updateCase(3)
        break

      case 52:
        updateCase(9)
        break

      case 48:
      case 53:
      case 192:
        updateCase(0)
        break

      case 88:
        changeTab('special')
        break

      case 67:
        changeTab('generic')
        break

      default:
        break
    }
  }
</script>

<style lang="scss">
  $gutter: 0.75rem;

  .container {
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    @include bgcolor(rgba(#000, 0.65));
  }

  .dialog {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    // margin-top: -10%;
    @include bgcolor(white);
    @include radius();
    @include shadow(3);
  }

  $header-height: 2.75rem;
  $header-gutter: 0.5rem;

  .header {
    position: relative;
    padding: $header-gutter $gutter;
    height: $header-height;
    line-height: $header-height - $header-gutter * 2;
    @include bgcolor(neutral, 1);
    @include radius($sides: top);
    @include border($sides: bottom);

    .label {
      font-weight: 500;
      @include fgcolor(neutral, 7);
    }

    .m-button {
      position: absolute;
      right: $header-gutter;
      // top: 0.375rem;
      top: 0.25rem;
      @include hover {
        color: color(primary, 5);
      }
    }

    .tab {
      display: inline-block;
      cursor: pointer;
      text-transform: uppercase;
      margin-left: $header-gutter;
      font-weight: 500;
      padding: 0 0.75rem;
      height: $header-height - $header-gutter * 2;

      @include font-size(2);
      @include fgcolor(neutral, 6);

      @include radius();

      @include border();

      &._active {
        @include bgcolor(#fff);
        @include fgcolor(primary, 6);
        @include bdcolor($color: primary, $shade: 4);
      }
    }
  }

  .content {
    padding: 0 0.75rem;
  }

  $label-width: 3rem;

  .source {
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;
  }

  .key-field {
    display: block;
    width: 100%;

    padding: 0.375rem 0.75rem;
    line-height: 1.5rem;

    @include radius();

    @include bgcolor(neutral, 1);
    @include border($color: color(neutral, 2));

    &:focus {
      @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 3);
    }
    // line-height: .75rem;
  }

  .translit {
    margin-top: 0.375rem;
    padding: 0 0.75rem;
    line-height: 1;
    @include truncate();
    @include font-size(2);
    @include fgcolor(neutral, 6);
  }

  $suggests-height: 2rem;
  $titleize-height: 2rem;
  $val-line-height: 2.5rem;

  .working {
    position: relative;
    margin: 0.5rem 0;

    .val-field {
      display: block;
      width: 100%;
      height: $suggests-height + $titleize-height + 3rem;

      margin: 0;
      line-height: 1.5rem;

      padding-left: 0.75rem;
      padding-right: 0.75rem;

      padding-top: $suggests-height;
      padding-bottom: $titleize-height;

      @include radius();
      @include border($color: color(neutral, 2));
      @include bgcolor(neutral, 1);

      &:focus,
      &:active {
        @include bgcolor(white);
        @include bdcolor($color: primary, $shade: 3);
      }

      &._fresh {
        font-style: italic;
      }
    }
  }

  .suggests {
    position: absolute;
    // width: 100%;
    height: $suggests-height;
    bottom: 1px;
    left: 1px;
    right: 1px;
    padding: 0.25rem 0.75rem;

    @include flex($gap: 0.25rem, $child: '.suggest');
    @include font-size(2);
    // @include bgcolor(neutral, 1);
    @include border($sides: top, $color: color(neutral, 2));
    @include radius($sides: bottom);

    .suggest {
      font-style: italic;
      line-height: 1.5rem;
      height: 1.5rem;

      padding: 0 0.25rem;

      @include fgcolor(primary, 6);
      @include bgcolor(neutral, 1);
      @include radius;
      &:hover {
        cursor: pointer;
        @include bgcolor(primary, 1);
      }
    }

    .mftime {
      font-style: italic;
      margin-left: auto;

      line-height: 1.5rem;
      height: 1.5rem;
      // @include truncate();
      @include font-size(2);
      @include fgcolor(neutral, 5);
    }
  }

  .capitalize {
    position: absolute;
    top: 1px;
    left: 1px;
    right: 1px;
    display: flex;
    // justify-content: center;

    padding: 0.25rem 0.75rem;
    line-height: 1.5rem;

    // @include bgcolor(neutral, 1);
    @include border($sides: bottom, $color: color(neutral, 2));
    @include radius($sides: top);

    text-transform: uppercase;
    font-weight: 500;
    @include font-size(1);
    @include fgcolor(neutral, 5);

    .cap-btn {
      padding: 0 0.375rem;
      // max-width: 20vw;
      cursor: pointer;
      @include truncate(null);

      @include radius();
      @include hover {
        @include bgcolor(primary, 1);
        @include fgcolor(primary, 5);
      }
    }
  }

  .actions {
    // margin: .75rem 0;
    margin: 0.5rem 0;

    @include flex($gap: 0.5rem, $child: '.m-button');

    .m-button {
      margin-left: auto;
    }
  }

  .footer {
    display: flex;
    align-items: center;
    justify-content: center;

    margin: 0;
    border-top: 1px solid color(neutral, 3);

    @include bgcolor(neutral, 1);
    @include radius($sides: bottom);

    a {
      // display: inline-block;
      line-height: 1rem;
      padding: 0.5rem;
      border-left: 1px splid color(neutral, 3);

      // max-width: 25vw;
      // overflow: hidden;
      // @include truncate();

      @include font-size(2);
      @include fgcolor(neutral, 7);

      @include hover {
        cursor: pointer;
        background-color: color(neutral, 3);
      }
    }
  }
</style>

<svelte:window on:keydown={handleKeypress} />

<div class="container" on:click={() => (active = false)}>
  <div class="dialog" on:click={(evt) => evt.stopPropagation()}>
    <header class="header">
      <span class="label">Từ điển</span>
      {#each tabs as [name, label]}
        <span
          class="tab"
          class:_active={name == tab}
          on:click={() => changeTab(name)}>
          {label}
        </span>
      {/each}

      <button
        type="button"
        class="m-button _text"
        on:click={() => (active = false)}>
        <svg class="m-icon _x">
          <use xlink:href="/icons.svg#x" />
        </svg>
      </button>
    </header>

    <div class="content">

      <section class="source">
        <div class="chinese">
          <input
            class="key-field"
            type="text"
            name="key"
            bind:value={key}
            bind:this={keyField} />
        </div>

        <div class="translit">
          {#if key}
            <span class="hanviet">{props.hanviet}</span>
            <span class="binh_am">[{props.binh_am}]</span>
          {/if}
        </div>
      </section>

      <section class="working">
        <input
          type="text"
          lang="vi"
          class="val-field"
          class:_fresh={isNewEntry}
          name="value"
          id="valField"
          on:keypress={submitOnEnter}
          bind:this={valField}
          bind:value={outValue} />

        <div class="suggests">
          {#each suggests as suggest}
            <span class="suggest" on:click={() => replaceValue(suggest)}>
              {suggest}
            </span>
          {/each}

          <span class="mftime">
            <span class="text">Lưu:</span>
            <span class="time">{mtime > 0 ? relative_time(mtime) : '--'}</span>
          </span>
        </div>

        <div class="capitalize">
          <span class="cap-btn" on:click={() => updateCase(1)}>
            Hoa một chữ
          </span>
          <span class="cap-btn" on:click={() => updateCase(2)}>Hai chữ</span>
          <span class="cap-btn" on:click={() => updateCase(3)}>Ba chữ</span>
          <span class="cap-btn" on:click={() => updateCase(99)}>
            Hoa toàn bộ
          </span>
          <span class="cap-btn" on:click={() => updateCase(0)}>Không hoa</span>
        </div>
      </section>

      <section class="actions">
        <button
          type="button"
          class="m-button _line _harmful"
          on:click={() => upsertData('')}>
          <span>Xoá từ</span>
        </button>

        <button
          type="button"
          class="m-button {isNewEntry ? '_primary' : '_success'}"
          on:click={() => upsertData(outValue)}>
          <span>{isNewEntry ? 'Thêm từ' : 'Sửa từ'}</span>
        </button>

      </section>

    </div>

    <footer class="footer">
      {#each links as { site, href }}
        <a {href} target="_blank" rel="noopener noreferer">{site}</a>
      {/each}
    </footer>
  </div>
</div>
