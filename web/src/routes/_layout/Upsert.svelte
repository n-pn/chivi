<script>
  import { onMount } from 'svelte'
  import relative_time from '$utils/relative_time'

  import Footer from './Upsert/Footer.svelte'

  const tabs = [
    ['special', 'VP riêng'],
    ['generic', 'VP chung'],
    // ['hanviet', 'Hán việt'],
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

  $: mftime = props[tab].mftime
  $: suggests = makeSuggests(tab, outValue, oldValue)
  $: actionType = outValue == '' ? 'Xoá từ' : isNewEntry ? 'Thêm từ' : 'Sửa từ'

  function makeSuggests(tab, reject, accept) {
    let hanviet = props.hanviet
    if (hanviet == reject) reject = null

    let output = [
      hanviet,
      ...props.suggest.vals,
      ...props.special.vals,
      ...props.generic.vals,
    ]

    if (tab === 'special') output.push(titleize(hanviet, 9))
    if (accept) output.push(accept)

    return output.filter((v, i, s) => s.indexOf(v) === i && v !== reject)
  }

  let props = {
    hanviet: '',
    binh_am: '',
    suggest: { vals: [], extra: '' },
    generic: { vals: [], mftime: 0, extra: '' },
    special: { vals: [], mftime: 0, extra: '' },
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

      if (suggests.length > 0) outValue = suggests[suggests.length - 1]
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
    @include bgcolor(neutral, 1);
    @include radius();
    @include shadow(3);
  }

  $header-height: 2.75rem;
  $header-gutter: 0.5rem;

  .header {
    position: relative;
    // padding: $header-gutter $gutter;
    height: $header-height;

    display: flex;
    @include border($sides: bottom, $shade: 3);

    .m-button {
      margin: 0.25rem 0.5rem;
      // top: 0.375rem;
      @include hover {
        color: color(primary, 5);
      }
    }
  }

  .label {
    line-height: $header-height;
    text-transform: uppercase;
    @include font-size(2);
    font-weight: 500;
    margin: 0 0.75rem;
    @include fgcolor(neutral, 6);
  }

  .hanzi {
    display: inline-block;
    margin: 0.375rem 0;

    padding: 0 0.375rem;
    line-height: $header-height - 0.875rem;

    flex-grow: 1;

    @include truncate(null);
    @include radius();

    @include bgcolor(neutral, 1);
    @include border($color: color(neutral, 1));

    &:focus {
      // @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 4);
    }
  }

  .tabs {
    margin-top: 0.75rem;
    @include border($sides: bottom);
    @include flex($gap: 0.5rem);
    padding: 0 0.75rem;
    height: 2rem;
    line-height: 2rem;
    // justify-content: center;
  }

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;
    height: 2rem;
    margin-top: 0.25px;

    @include font-size(2);
    @include fgcolor(neutral, 6);

    @include radius();
    @include radius(0, $sides: bottom);

    @include border($color: neutral);
    @include border($color: none, $sides: bottom);

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
      // @include bdwidth(2px, $sides: top);
      @include bdcolor($color: none, $sides: bottom);
    }
  }

  .body {
    @include bgcolor(#fff);
    padding: 0.75rem;
  }

  $label-width: 3rem;

  $suggests-height: 2rem;
  $titleize-height: 2rem;
  $val-line-height: 2.5rem;

  .output {
    @include bgcolor(neutral, 1);

    .val-field {
      display: block;
      width: 100%;

      margin: 0;

      line-height: 1.5rem;
      padding: 0.75rem;

      border: none;
      @include border();
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

  .hints {
    // width: 100%;
    // height: $suggests-height;

    padding: 0.25rem 0.5rem;

    @include border();
    border-bottom: none;
    @include radius($sides: top);

    @include flex($gap: 0.25rem, $child: '.hint');
    @include font-size(2);

    .hint {
      font-style: italic;
      line-height: 1.5rem;
      height: 1.5rem;

      padding: 0 0.25rem;
      max-width: 25vw;
      @include truncate(null);

      @include fgcolor(neutral, 6);
      @include bgcolor(neutral, 1);
      @include radius;
      &:hover {
        cursor: pointer;
        @include fgcolor(primary, 6);
        @include bgcolor(primary, 1);
      }

      &._binh_am {
        margin-left: auto;
      }
    }
  }

  .format {
    display: flex;
    padding: 0 0.5rem;

    @include border();
    border-top: none;
    @include radius($sides: bottom);

    font-size: rem(10px);
    @include screen-min(sm) {
      font-size: rem(11px);
    }
    @include screen-min(md) {
      font-size: rem(12px);
    }

    .-cap,
    .-etc {
      display: flex;
    }

    .-etc {
      margin-left: auto;
    }

    .-btn {
      display: inline-block;
      cursor: pointer;
      padding: 0 0.375rem;
      line-height: 2.25rem;
      font-weight: 500;
      text-transform: uppercase;

      max-width: 14vw;
      @include truncate(null);
      @include fgcolor(neutral, 5);

      @include hover {
        @include fgcolor(primary, 5);
        @include bgcolor(#fff);
      }
    }
  }

  .footer {
    margin-top: 0.75rem;

    @include flex($gap: 0.5rem, $child: '.m-button');

    .m-button {
      margin-left: auto;
    }
  }
</style>

<svelte:window on:keydown={handleKeypress} />

<div class="container" on:click={() => (active = false)}>
  <div class="dialog" on:click|stopPropagation={refocusOnValField}>
    <header class="header">
      <span class="label">Thêm từ:</span>

      <span
        class="hanzi"
        role="textbox"
        contenteditable="true"
        on:click|stopPropagation={() => keyField.focus()}
        bind:textContent={key}
        bind:this={keyField} />

      <button
        type="button"
        class="m-button _text"
        on:click={() => (active = false)}>
        <svg class="m-icon _x">
          <use xlink:href="/icons.svg#x" />
        </svg>
      </button>
    </header>

    <section class="tabs">
      {#each tabs as [name, label]}
        <span
          class="tab"
          class:_active={name == tab}
          on:click={() => changeTab(name)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="output">
        <div class="hints">
          {#each suggests as suggest}
            <span class="hint" on:click={() => replaceValue(suggest)}>
              {suggest}
            </span>
          {/each}

          <span class="hint _binh_am">[{props.binh_am}]</span>
        </div>

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

        <div class="format">
          <div class="-cap">
            <span class="-btn" on:click={() => updateCase(1)}>Hoa 1 chữ</span>
            <span class="-btn" on:click={() => updateCase(2)}>Hai chữ</span>
            <span class="-btn" on:click={() => updateCase(3)}>Ba chữ</span>
            <span class="-btn" on:click={() => updateCase(99)}>Toàn bộ</span>
            <span class="-btn" on:click={() => updateCase(0)}>Không hoa</span>
          </div>

          <div class="-etc">
            <span class="-btn" on:click={() => (outValue = defaultVal(tab))}>
              Phục
            </span>
            <span class="-btn" on:click={() => (outValue = '')}>Xoá</span>
          </div>
        </div>
      </div>

      <div class="footer">

        {#if mftime > 0}
          <span class="mftime">
            <span class="text">Lưu:</span>
            <span class="time">{relative_time(mftime)}</span>
          </span>
        {/if}

        <button
          type="button"
          class="m-button {tab == 'special' ? '_primary' : '_success'}"
          class:_line={!isNewEntry}
          disabled={outValue == defaultVal(tab)}
          on:click={() => upsertData(outValue)}>
          <span>{actionType}</span>
        </button>
      </div>
    </section>

    <Footer {key} />

  </div>
</div>
